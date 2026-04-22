const std = @import("std");
const builtin = @import("builtin");
const sp = @import("Zigspinner");

fn configureTerminalOutput() void {
    if (builtin.os.tag != .windows) return;

    const win = std.os.windows;
    const SetConsoleOutputCP = @extern(
        *const fn (code_page_id: win.UINT) callconv(.winapi) win.BOOL,
        .{ .name = "SetConsoleOutputCP", .library_name = "kernel32" },
    );
    _ = SetConsoleOutputCP(65001);
}

pub fn main() !void {
    configureTerminalOutput();

    var spinner = sp.presets.emoji.moon();
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
