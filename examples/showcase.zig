const std = @import("std");
const sp = @import("Zigspinner");
const builtin = @import("builtin");

const CompatOut = struct {
    pub fn print(_: CompatOut, comptime fmt: []const u8, args: anytype) !void {
        std.debug.print(fmt, args);
    }

    pub fn flush(_: CompatOut) !void {
        return;
    }
};

fn framePause(ns: u64) void {
    if (@hasDecl(std, "Io") and @hasDecl(std.Io, "sleep") and @hasDecl(std.Options, "debug_io")) {
        std.Io.sleep(std.Options.debug_io, std.Io.Duration.fromNanoseconds(@intCast(ns)), .awake) catch {};
        return;
    }

    if (@hasDecl(std.Thread, "sleep")) {
        std.Thread.sleep(ns);
        return;
    }

    const yields: usize = @intCast(@max(@as(u64, 1), ns / 200_000));
    var i: usize = 0;
    while (i < yields) : (i += 1) {
        _ = std.Thread.yield() catch {};
    }
}

const panel_width: usize = 62; // visual columns per panel

// ---------------------------------------------------------------------------
// Unicode / display-width helpers
// ---------------------------------------------------------------------------

/// Terminal display width of a single Unicode codepoint (wcwidth).
/// Returns 2 for emoji, CJK, and other fullwidth characters; 1 otherwise.
/// Returns 0 for zero-width combiners/selectors.
fn codepointDisplayWidth(cp: u21) usize {
    // Fast path: plain ASCII
    if (cp < 0x80) return 1;

    // Zero-width: combining marks, ZWJ, etc.
    if (cp == 0x200D) return 0; // ZWJ — handled by caller
    if (cp >= 0x0300 and cp <= 0x036F) return 0; // combining diacriticals
    if (cp >= 0x1F3FB and cp <= 0x1F3FF) return 0; // skin-tone modifiers

    // Variation selector U+FE0F selects emoji presentation (2 cols).
    // We return 1 here so the caller can upgrade the previous char if needed.
    // Actually we handle FE0F separately in displayWidth / utf8PrefixCols.
    if (cp >= 0xFE00 and cp <= 0xFE0E) return 0; // VS1-VS15 (text variation)
    if (cp == 0xFE0F) return 0; // VS16 — emoji variation; caller upgrades prev

    // Emoji ranges — all render as 2 columns in modern terminals
    if (cp >= 0x1F300 and cp <= 0x1F5FF) return 2; // misc symbols & pictographs
    if (cp >= 0x1F600 and cp <= 0x1F64F) return 2; // emoticons
    if (cp >= 0x1F680 and cp <= 0x1F6FF) return 2; // transport & map
    if (cp >= 0x1F900 and cp <= 0x1F9FF) return 2; // supplemental symbols
    if (cp >= 0x1FA00 and cp <= 0x1FAFF) return 2; // symbols extended-A
    if (cp >= 0x1F100 and cp <= 0x1F2FF) return 2; // enclosed supplement
    if (cp >= 0x2702 and cp <= 0x27B0) return 2; // dingbats
    // Misc symbols U+2600–26FF: only upgrade to 2 when followed by VS16 (FE0F).
    // Without VS16 these are 1-col text glyphs (☀ ♥ ⛈ etc.).
    if (cp >= 0x2600 and cp <= 0x26FF) return 1; // upgraded by caller on VS16
    // CJK
    if (cp >= 0x4E00 and cp <= 0x9FFF) return 2;
    if (cp >= 0x3000 and cp <= 0x303F) return 2;
    if (cp >= 0xFF00 and cp <= 0xFFEF) return 2;
    if (cp >= 0x20000 and cp <= 0x2A6DF) return 2;

    return 1;
}

/// Display width (terminal columns) of a UTF-8 string.
/// Handles U+FE0F (VS16): upgrades the previous codepoint from 1→2 cols
/// if it was a misc-symbol that renders as emoji with the selector.
fn displayWidth(text: []const u8) usize {
    var width: usize = 0;
    var i: usize = 0;
    while (i < text.len) {
        const seq_len = std.unicode.utf8ByteSequenceLength(text[i]) catch {
            i += 1;
            width += 1;
            continue;
        };
        if (i + seq_len > text.len) break;
        const cp = std.unicode.utf8Decode(text[i .. i + seq_len]) catch {
            i += seq_len;
            width += 1;
            continue;
        };
        if (cp == 0xFE0F) {
            // VS16: if the previous char was counted as 1, upgrade to 2
            if (width > 0) width += 1;
        } else {
            width += codepointDisplayWidth(cp);
        }
        i += seq_len;
    }
    return width;
}

/// Clip `text` so its *display width* does not exceed `max_cols`.
/// Handles U+FE0F upgrading the previous char width.
fn utf8PrefixCols(text: []const u8, max_cols: usize) []const u8 {
    var cols: usize = 0;
    var i: usize = 0;
    while (i < text.len) {
        const seq_len = std.unicode.utf8ByteSequenceLength(text[i]) catch {
            if (cols + 1 > max_cols) break;
            i += 1;
            cols += 1;
            continue;
        };
        if (i + seq_len > text.len) break;
        const cp = std.unicode.utf8Decode(text[i .. i + seq_len]) catch {
            if (cols + 1 > max_cols) break;
            i += seq_len;
            cols += 1;
            continue;
        };
        if (cp == 0xFE0F) {
            // VS16 upgrade: costs 1 extra col if previous was 1-wide
            if (cols > 0 and cols + 1 <= max_cols) {
                cols += 1;
                i += seq_len;
            } else if (cols > 0 and cols + 1 > max_cols) {
                // Can't fit the upgrade — stop before the VS16
                break;
            } else {
                i += seq_len; // zero-cost at start (shouldn't happen)
            }
        } else {
            const w = codepointDisplayWidth(cp);
            if (cols + w > max_cols) break;
            cols += w;
            i += seq_len;
        }
    }
    return text[0..i];
}

// ---------------------------------------------------------------------------
// Low-level drawing helpers
// ---------------------------------------------------------------------------

fn writeRepeat(out: anytype, comptime text: []const u8, count: usize) !void {
    var i: usize = 0;
    while (i < count) : (i += 1) {
        try out.print("{s}", .{text});
    }
}

/// Print `text` clipped to `width` *visual columns*, then pad with spaces.
fn writePadded(out: anytype, text: []const u8, width: usize) !void {
    const clipped = utf8PrefixCols(text, width);
    try out.print("{s}", .{clipped});
    const used_cols = displayWidth(clipped);
    if (width > used_cols) {
        try writeRepeat(out, " ", width - used_cols);
    }
}

// ---------------------------------------------------------------------------
// Panel drawing
// ---------------------------------------------------------------------------

fn drawTopBorder(out: anytype, title: []const u8) !void {
    const inner = panel_width - 2; // visual columns between the corner chars

    // " title " — measure in display columns
    const title_w = displayWidth(title);
    // +2 for the surrounding spaces
    const header_cols = @min(title_w + 2, inner);

    // Print corner + space + title (clipped) + space
    try out.print("┌ ", .{});
    const title_space = if (header_cols >= 2) header_cols - 2 else 0;
    const clipped_title = utf8PrefixCols(title, title_space);
    try out.print("{s} ", .{clipped_title});

    // Fill remaining columns with ─
    if (inner > header_cols) {
        try writeRepeat(out, "─", inner - header_cols);
    }
    try out.print("┐", .{});
}

fn drawMiddleRow(out: anytype, content: []const u8) !void {
    const inner = panel_width - 2;
    try out.print("│", .{});
    try writePadded(out, content, inner);
    try out.print("│", .{});
}

fn drawBottomBorder(out: anytype) !void {
    try out.print("└", .{});
    try writeRepeat(out, "─", panel_width - 2);
    try out.print("┘", .{});
}

fn drawPanelPair(
    out: anytype,
    left_title: []const u8,
    right_title: []const u8,
    left_rows: []const []const u8,
    right_rows: []const []const u8,
) !void {
    try drawTopBorder(out, left_title);
    try out.print(" ", .{});
    try drawTopBorder(out, right_title);
    try out.print("\n", .{});

    const row_count = @max(left_rows.len, right_rows.len);
    var i: usize = 0;
    while (i < row_count) : (i += 1) {
        const left = if (i < left_rows.len) left_rows[i] else "";
        const right = if (i < right_rows.len) right_rows[i] else "";
        try drawMiddleRow(out, left);
        try out.print(" ", .{});
        try drawMiddleRow(out, right);
        try out.print("\n", .{});
    }

    try drawBottomBorder(out);
    try out.print(" ", .{});
    try drawBottomBorder(out);
    try out.print("\n", .{});
}

// ---------------------------------------------------------------------------
// Row formatters — display-width aware, no std.fmt byte-padding
// inner panel = panel_width - 2 = 56 display columns
// ---------------------------------------------------------------------------

/// Write `text` padded to exactly `col_width` display columns into `buf`.
/// Returns bytes written.
fn writePaddedToBuf(buf: []u8, text: []const u8, col_width: usize) usize {
    const clipped = utf8PrefixCols(text, col_width);
    const used = displayWidth(clipped);
    const spaces = if (col_width > used) col_width - used else 0;
    var n: usize = 0;
    @memcpy(buf[n .. n + clipped.len], clipped);
    n += clipped.len;
    @memset(buf[n .. n + spaces], ' ');
    n += spaces;
    return n;
}

// 1-cell: label(16) + '  ' + frame(38) = 56
fn makeRow(buf: []u8, label: []const u8, frame: []const u8) []const u8 {
    var n: usize = 0;
    n += writePaddedToBuf(buf[n..], label, 16);
    buf[n] = ' ';
    n += 1;
    buf[n] = ' ';
    n += 1;
    n += writePaddedToBuf(buf[n..], frame, 38);
    return buf[0..n];
}

// 2-cell: label1(18)+' '+frame1(2)+'  '+label2(18)+' '+frame2(16) = 56
//   col-A: 18+1+2 = 21   gap: 2   col-B: 18+1+14 = 33  total = 21+2+33 = 56
fn makeRow2(buf: []u8, l1: []const u8, f1: []const u8, l2: []const u8, f2: []const u8) []const u8 {
    var n: usize = 0;
    n += writePaddedToBuf(buf[n..], l1, 18);
    buf[n] = ' ';
    n += 1;
    n += writePaddedToBuf(buf[n..], f1, 2);
    buf[n] = ' ';
    n += 1;
    buf[n] = ' ';
    n += 1;
    n += writePaddedToBuf(buf[n..], l2, 18);
    buf[n] = ' ';
    n += 1;
    n += writePaddedToBuf(buf[n..], f2, 14);
    return buf[0..n];
}

// 3-cell: label(12)+' '+frame(2)+'     ' + label(12)+' '+frame(2)+'     ' + label(12)+' '+frame(3) = 56
fn makeRow3(buf: []u8, l1: []const u8, f1: []const u8, l2: []const u8, f2: []const u8, l3: []const u8, f3: []const u8) []const u8 {
    var n: usize = 0;
    n += writePaddedToBuf(buf[n..], l1, 12);
    buf[n] = ' ';
    n += 1;
    n += writePaddedToBuf(buf[n..], f1, 2);
    buf[n] = ' ';
    n += 1;
    buf[n] = ' ';
    n += 1;
    buf[n] = ' ';
    n += 1;
    buf[n] = ' ';
    n += 1;
    buf[n] = ' ';
    n += 1;
    n += writePaddedToBuf(buf[n..], l2, 12);
    buf[n] = ' ';
    n += 1;
    n += writePaddedToBuf(buf[n..], f2, 2);
    buf[n] = ' ';
    n += 1;
    buf[n] = ' ';
    n += 1;
    buf[n] = ' ';
    n += 1;
    buf[n] = ' ';
    n += 1;
    buf[n] = ' ';
    n += 1;
    n += writePaddedToBuf(buf[n..], l3, 12);
    buf[n] = ' ';
    n += 1;
    n += writePaddedToBuf(buf[n..], f3, 3);
    return buf[0..n];
}

// ---------------------------------------------------------------------------
// Misc helpers
// ---------------------------------------------------------------------------

fn configureWindowsUtf8Console() void {
    if (builtin.os.tag != .windows) return;
    const win = std.os.windows;
    if (@hasDecl(win.kernel32, "SetConsoleOutputCP")) {
        _ = win.kernel32.SetConsoleOutputCP(65001);
    }
}

fn setupWindowsRawInput() ?u32 {
    if (builtin.os.tag != .windows) return null;
    const win = std.os.windows;
    if (!@hasDecl(win.kernel32, "GetStdHandle") or
        !@hasDecl(win.kernel32, "GetConsoleMode") or
        !@hasDecl(win.kernel32, "SetConsoleMode"))
    {
        return null;
    }
    const stdin_handle = win.kernel32.GetStdHandle(win.STD_INPUT_HANDLE) orelse return null;

    var mode: u32 = 0;
    if (win.kernel32.GetConsoleMode(stdin_handle, &mode) == 0) return null;

    const ENABLE_LINE_INPUT: u32 = 0x0002;
    const ENABLE_ECHO_INPUT: u32 = 0x0004;
    const new_mode = mode & ~(ENABLE_LINE_INPUT | ENABLE_ECHO_INPUT);
    if (win.kernel32.SetConsoleMode(stdin_handle, new_mode) == 0) return null;
    return mode;
}

fn restoreWindowsInputMode(old_mode: ?u32) void {
    if (builtin.os.tag != .windows or old_mode == null) return;
    const win = std.os.windows;
    if (!@hasDecl(win.kernel32, "GetStdHandle") or !@hasDecl(win.kernel32, "SetConsoleMode")) return;
    const stdin_handle = win.kernel32.GetStdHandle(win.STD_INPUT_HANDLE) orelse return;
    _ = win.kernel32.SetConsoleMode(stdin_handle, old_mode.?);
}

// ---------------------------------------------------------------------------
// Input thread
// ---------------------------------------------------------------------------

const SharedInput = struct {
    reverse_requests: std.atomic.Value(u32) = std.atomic.Value(u32).init(0),
    quit: std.atomic.Value(bool) = std.atomic.Value(bool).init(false),
};

fn inputLoop(shared: *SharedInput) void {
    if (builtin.zig_version.minor >= 16) {
        const in = std.Io.File.stdin();
        var stream_buf: [256]u8 = undefined;
        var byte_buf: [1]u8 = undefined;

        while (!shared.quit.load(.acquire)) {
            var in_reader = in.readerStreaming(std.Options.debug_io, &stream_buf);
            const n = in_reader.interface.readSliceShort(byte_buf[0..]) catch |err| switch (err) {
                error.ReadFailed => break,
            };
            if (n == 0) continue;

            switch (byte_buf[0]) {
                'q', 'Q', 27 => {
                    shared.quit.store(true, .release);
                    break;
                },
                'r', 'R' => _ = shared.reverse_requests.fetchAdd(1, .acq_rel),
                else => {},
            }
        }
        return;
    }

    const in = std.fs.File.stdin();
    var byte_buf: [1]u8 = undefined;
    while (!shared.quit.load(.acquire)) {
        const n = in.read(&byte_buf) catch break;
        if (n == 0) continue;

        switch (byte_buf[0]) {
            'q', 'Q', 27 => {
                shared.quit.store(true, .release);
                break;
            },
            'r', 'R' => _ = shared.reverse_requests.fetchAdd(1, .acq_rel),
            else => {},
        }
    }
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

fn fr(comptime T: type, spinner: T, rev: bool, t: u64) []const u8 {
    return if (rev) spinner.reverse().frameAt(t) else spinner.frameAt(t);
}

pub fn main() !void {
    configureWindowsUtf8Console();
    const old_mode = setupWindowsRawInput();
    defer restoreWindowsInputMode(old_mode);

    const out = CompatOut{};

    try out.print("\x1b[?1049h\x1b[?25l", .{});
    try out.flush();
    defer {
        out.print("\x1b[?25h\x1b[?1049l", .{}) catch {};
        out.flush() catch {};
    }

    const a_arrow = sp.presets.arrows.arrow();
    const a_double = sp.presets.arrows.double_arrow();

    const x_dqpb = sp.presets.ascii.dqpb();
    const x_rolling = sp.presets.ascii.rolling_line();
    const x_simple = sp.presets.ascii.simple_dots();
    const x_simple_scroll = sp.presets.ascii.simple_dots_scrolling();
    const x_arc = sp.presets.ascii.arc();
    const x_balloon = sp.presets.ascii.balloon();
    const x_halves = sp.presets.ascii.circle_halves();
    const x_quarters = sp.presets.ascii.circle_quarters();
    const x_point = sp.presets.ascii.point();
    const x_square = sp.presets.ascii.square_corners();
    const x_toggle = sp.presets.ascii.toggle();
    const x_triangle = sp.presets.ascii.triangle();
    const x_grow_h = sp.presets.ascii.grow_horizontal();
    const x_grow_v = sp.presets.ascii.grow_vertical();
    const x_noise = sp.presets.ascii.noise();

    const b_dots = sp.presets.braille.dots();
    const b_dots2 = sp.presets.braille.dots2();
    const b_dots3 = sp.presets.braille.dots3();
    const b_dots4 = sp.presets.braille.dots4();
    const b_dots5 = sp.presets.braille.dots5();
    const b_dots6 = sp.presets.braille.dots6();
    const b_dots7 = sp.presets.braille.dots7();
    const b_dots8 = sp.presets.braille.dots8();
    const b_dots9 = sp.presets.braille.dots9();
    const b_dots10 = sp.presets.braille.dots10();
    const b_dots11 = sp.presets.braille.dots11();
    const b_dots12 = sp.presets.braille.dots12();
    const b_dots13 = sp.presets.braille.dots13();
    const b_dots14 = sp.presets.braille.dots14();
    const b_dots_circle = sp.presets.braille.dots_circle();
    const b_sand = sp.presets.braille.sand();
    const b_bounce = sp.presets.braille.bounce();
    const b_wave = sp.presets.braille.wave();
    const b_scan = sp.presets.braille.scan();
    const b_rain = sp.presets.braille.rain();
    const b_pulse = sp.presets.braille.pulse();
    const b_snake = sp.presets.braille.snake();
    const b_sparkle = sp.presets.braille.sparkle();
    const b_cascade = sp.presets.braille.cascade();
    const b_columns = sp.presets.braille.columns();
    const b_orbit = sp.presets.braille.orbit();
    const b_breathe = sp.presets.braille.breathe();
    const b_waverows = sp.presets.braille.waverows();
    const b_checkerboard = sp.presets.braille.checkerboard();
    const b_helix = sp.presets.braille.helix();
    const b_fillsweep = sp.presets.braille.fillsweep();
    const b_diagswipe = sp.presets.braille.diagswipe();
    const b_infinity = sp.presets.braille.infinity();

    const e_hearts = sp.presets.emoji.hearts();
    const e_clock = sp.presets.emoji.clock();
    const e_earth = sp.presets.emoji.earth();
    const e_moon = sp.presets.emoji.moon();
    const e_speaker = sp.presets.emoji.speaker();
    const e_weather = sp.presets.emoji.weather();

    var reverse_on = false;
    var seen_reverse_requests: u32 = 0;

    var shared_input = SharedInput{};
    var input_thread = try std.Thread.spawn(.{}, inputLoop, .{&shared_input});
    defer {
        shared_input.quit.store(true, .release);
        input_thread.detach();
    }

    var step: u64 = 0;
    while (!shared_input.quit.load(.acquire)) : (step += 1) {
        const elapsed = step * 90_000_000;

        const requests = shared_input.reverse_requests.load(.acquire);
        if (requests != seen_reverse_requests) {
            seen_reverse_requests = requests;
            reverse_on = !reverse_on;
        }

        var arrows_buf: [2][192]u8 = undefined;
        const arrows_rows = [_][]const u8{
            makeRow(&arrows_buf[0], "arrow", fr(@TypeOf(a_arrow), a_arrow, reverse_on, elapsed)),
            makeRow(&arrows_buf[1], "double_arrow", fr(@TypeOf(a_double), a_double, reverse_on, elapsed)),
        };

        var ascii_buf: [10][192]u8 = undefined;
        const ascii_rows = [_][]const u8{
            makeRow2(&ascii_buf[0], "dqpb", fr(@TypeOf(x_dqpb), x_dqpb, reverse_on, elapsed), "toggle", fr(@TypeOf(x_toggle), x_toggle, reverse_on, elapsed)),
            makeRow2(&ascii_buf[1], "rolling_line", fr(@TypeOf(x_rolling), x_rolling, reverse_on, elapsed), "triangle", fr(@TypeOf(x_triangle), x_triangle, reverse_on, elapsed)),
            makeRow2(&ascii_buf[2], "simple_dots", fr(@TypeOf(x_simple), x_simple, reverse_on, elapsed), "grow_horizontal", fr(@TypeOf(x_grow_h), x_grow_h, reverse_on, elapsed)),
            makeRow2(&ascii_buf[3], "simple_dots_scrolling", fr(@TypeOf(x_simple_scroll), x_simple_scroll, reverse_on, elapsed), "grow_vertical", fr(@TypeOf(x_grow_v), x_grow_v, reverse_on, elapsed)),
            makeRow2(&ascii_buf[4], "arc", fr(@TypeOf(x_arc), x_arc, reverse_on, elapsed), "noise", fr(@TypeOf(x_noise), x_noise, reverse_on, elapsed)),
            makeRow(&ascii_buf[5], "balloon", fr(@TypeOf(x_balloon), x_balloon, reverse_on, elapsed)),
            makeRow(&ascii_buf[6], "circle_halves", fr(@TypeOf(x_halves), x_halves, reverse_on, elapsed)),
            makeRow(&ascii_buf[7], "circle_quarters", fr(@TypeOf(x_quarters), x_quarters, reverse_on, elapsed)),
            makeRow(&ascii_buf[8], "point", fr(@TypeOf(x_point), x_point, reverse_on, elapsed)),
            makeRow(&ascii_buf[9], "square_corners", fr(@TypeOf(x_square), x_square, reverse_on, elapsed)),
        };

        var braille_buf: [12][256]u8 = undefined;
        const braille_rows = [_][]const u8{
            makeRow3(&braille_buf[0], "dots", fr(@TypeOf(b_dots), b_dots, reverse_on, elapsed), "dots7", fr(@TypeOf(b_dots7), b_dots7, reverse_on, elapsed), "dots13", fr(@TypeOf(b_dots13), b_dots13, reverse_on, elapsed)),
            makeRow3(&braille_buf[1], "dots2", fr(@TypeOf(b_dots2), b_dots2, reverse_on, elapsed), "dots8", fr(@TypeOf(b_dots8), b_dots8, reverse_on, elapsed), "dots14", fr(@TypeOf(b_dots14), b_dots14, reverse_on, elapsed)),
            makeRow3(&braille_buf[2], "dots3", fr(@TypeOf(b_dots3), b_dots3, reverse_on, elapsed), "dots9", fr(@TypeOf(b_dots9), b_dots9, reverse_on, elapsed), "dots_circle", fr(@TypeOf(b_dots_circle), b_dots_circle, reverse_on, elapsed)),
            makeRow3(&braille_buf[3], "dots4", fr(@TypeOf(b_dots4), b_dots4, reverse_on, elapsed), "dots10", fr(@TypeOf(b_dots10), b_dots10, reverse_on, elapsed), "sand", fr(@TypeOf(b_sand), b_sand, reverse_on, elapsed)),
            makeRow3(&braille_buf[4], "dots5", fr(@TypeOf(b_dots5), b_dots5, reverse_on, elapsed), "dots11", fr(@TypeOf(b_dots11), b_dots11, reverse_on, elapsed), "bounce", fr(@TypeOf(b_bounce), b_bounce, reverse_on, elapsed)),
            makeRow3(&braille_buf[5], "dots6", fr(@TypeOf(b_dots6), b_dots6, reverse_on, elapsed), "dots12", fr(@TypeOf(b_dots12), b_dots12, reverse_on, elapsed), "braillewave", fr(@TypeOf(b_wave), b_wave, reverse_on, elapsed)),
            makeRow3(&braille_buf[6], "scan", fr(@TypeOf(b_scan), b_scan, reverse_on, elapsed), "rain", fr(@TypeOf(b_rain), b_rain, reverse_on, elapsed), "pulse", fr(@TypeOf(b_pulse), b_pulse, reverse_on, elapsed)),
            makeRow3(&braille_buf[7], "snake", fr(@TypeOf(b_snake), b_snake, reverse_on, elapsed), "sparkle", fr(@TypeOf(b_sparkle), b_sparkle, reverse_on, elapsed), "cascade", fr(@TypeOf(b_cascade), b_cascade, reverse_on, elapsed)),
            makeRow3(&braille_buf[8], "orbit", fr(@TypeOf(b_orbit), b_orbit, reverse_on, elapsed), "breathe", fr(@TypeOf(b_breathe), b_breathe, reverse_on, elapsed), "waverows", fr(@TypeOf(b_waverows), b_waverows, reverse_on, elapsed)),
            makeRow3(&braille_buf[9], "columns", fr(@TypeOf(b_columns), b_columns, reverse_on, elapsed), "checkerboard", fr(@TypeOf(b_checkerboard), b_checkerboard, reverse_on, elapsed), "helix", fr(@TypeOf(b_helix), b_helix, reverse_on, elapsed)),
            makeRow3(&braille_buf[10], "fillsweep", fr(@TypeOf(b_fillsweep), b_fillsweep, reverse_on, elapsed), "diagswipe", fr(@TypeOf(b_diagswipe), b_diagswipe, reverse_on, elapsed), "infinity", fr(@TypeOf(b_infinity), b_infinity, reverse_on, elapsed)),
            makeRow(&braille_buf[11], "", ""),
        };

        var emoji_buf: [6][192]u8 = undefined;
        const emoji_rows = [_][]const u8{
            makeRow(&emoji_buf[0], "hearts", fr(@TypeOf(e_hearts), e_hearts, reverse_on, elapsed)),
            makeRow(&emoji_buf[1], "clock", fr(@TypeOf(e_clock), e_clock, reverse_on, elapsed)),
            makeRow(&emoji_buf[2], "earth", fr(@TypeOf(e_earth), e_earth, reverse_on, elapsed)),
            makeRow(&emoji_buf[3], "moon", fr(@TypeOf(e_moon), e_moon, reverse_on, elapsed)),
            makeRow(&emoji_buf[4], "speaker", fr(@TypeOf(e_speaker), e_speaker, reverse_on, elapsed)),
            makeRow(&emoji_buf[5], "weather", fr(@TypeOf(e_weather), e_weather, reverse_on, elapsed)),
        };

        try out.print("\x1b[H", .{});
        try out.print("q - quit | r - reverse\n", .{});
        try drawPanelPair(out, "Arrows", "ASCII", arrows_rows[0..], ascii_rows[0..]);
        try drawPanelPair(out, "Braille", "Emoji", braille_rows[0..], emoji_rows[0..]);

        try out.flush();
        framePause(90_000_000);
    }
}
