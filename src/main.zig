const std = @import("std");
const sp = @import("Zigspinner");
const builtin = @import("builtin");

fn configureTerminalOutput() void {
    switch (builtin.os.tag) {
        .windows => {
            const win = std.os.windows;
            if (@hasDecl(win.kernel32, "SetConsoleOutputCP")) {
                _ = win.kernel32.SetConsoleOutputCP(65001);
            }
        },
        else => {},
    }
}

fn framePause(ns: u64) void {
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

pub fn main() !void {
    configureTerminalOutput();

    var spinner = sp.presets.braille.dots();
    var elapsed: u64 = 0;

    while (true) {
        std.debug.print("\r{s}", .{spinner.frameAt(elapsed)});

        if (elapsed >= 4_000_000_000) break;
        framePause(33_000_000);
        elapsed +%= 33_000_000;
    }

    std.debug.print("\rDone\n", .{});
}

test "preset spinner returns frame" {
    const spinner = sp.presets.ascii.rolling_line();
    try std.testing.expect(spinner.len() > 0);
    try std.testing.expect(spinner.frame(0).len > 0);
}
