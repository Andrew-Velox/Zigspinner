const std = @import("std");
const sp = @import("Zigspinner");

pub fn main() !void {
    var stdout_buffer: [2048]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const out = &stdout_writer.interface;

    try out.print("No-std style demo (external clock + ticked mode)\n\n", .{});

    const timed = sp.presets.braille.dots();
    var elapsed_ns: u64 = 0;

    try out.print("Timed with external elapsed value:\n", .{});
    for (0..10) |_| {
        try out.print("  t={d:>4}ms frame={s}\n", .{ elapsed_ns / 1_000_000, timed.frameAt(elapsed_ns) });
        elapsed_ns += timed.interval();
    }

    try out.print("\nTicked mode (no global clock):\n", .{});
    var ticked = sp.presets.ascii.simple_dots().intoTicked();
    for (0..8) |_| {
        try out.print("  idx={d:>2} frame={s}\n", .{ ticked.index(), ticked.currentFrame() });
        _ = ticked.tick();
    }

    try out.flush();
}
