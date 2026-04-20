const std = @import("std");
const sp = @import("Zigspinner");

pub fn main() !void {
    var spinner = sp.presets.braille.dots();

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;
    const start = std.time.nanoTimestamp();

    while (true) {
        const now = std.time.nanoTimestamp();
        const elapsed: u64 = @intCast(now - start);

        try stdout.print("\r{s}", .{spinner.frameAt(elapsed)});
        try stdout.flush();

        if (elapsed >= 4_000_000_000) break;
        std.Thread.sleep(33_000_000);
    }

    try stdout.print("\rDone\n", .{});
    try stdout.flush();
}

test "preset spinner returns frame" {
    const spinner = sp.presets.ascii.rolling_line();
    try std.testing.expect(spinner.len() > 0);
    try std.testing.expect(spinner.frame(0).len > 0);
}
