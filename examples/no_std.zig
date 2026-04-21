const std = @import("std");
const sp = @import("Zigspinner");

pub fn main() !void {
    std.debug.print("No-std style demo (external clock + ticked mode)\n\n", .{});

    const timed = sp.presets.braille.dots();
    var elapsed_ns: u64 = 0;

    std.debug.print("Timed with external elapsed value:\n", .{});
    for (0..10) |_| {
        std.debug.print("  t={d:>4}ms frame={s}\n", .{ elapsed_ns / 1_000_000, timed.frameAt(elapsed_ns) });
        elapsed_ns += timed.interval();
    }

    std.debug.print("\nTicked mode (no global clock):\n", .{});
    var ticked = sp.presets.ascii.simple_dots().intoTicked();
    for (0..8) |_| {
        std.debug.print("  idx={d:>2} frame={s}\n", .{ ticked.index(), ticked.currentFrame() });
        _ = ticked.tick();
    }
}
