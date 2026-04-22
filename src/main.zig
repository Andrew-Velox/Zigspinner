const std = @import("std");
const sp = @import("Zigspinner");

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
    var spinner = sp.presets.ascii.simple_dots_scrolling();
    var elapsed: u64 = 0;

    while (true) {
        std.debug.print("\r{s}", .{spinner.frameAt(elapsed)});

        framePause(30_000_000);
        elapsed +%= 30_000_000;
    }
}
