const std = @import("std");
const sp = @import("Zigspinner");

pub fn main() !void {
    var spinner = sp.presets.ascii.simple_dots_scrolling();
    var elapsed: u64 = 0;
    const step_ns: u64 = 30_000_000;

    while (true) {
        std.debug.print("\r{s}", .{spinner.frameAt(elapsed)});

        if (@hasDecl(std.Thread, "sleep")) {
            std.Thread.sleep(step_ns);
        } else {
            _ = std.Thread.yield() catch {};
        }
        elapsed +%= step_ns;
    }
}
