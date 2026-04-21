const std = @import("std");
const sp = @import("Zigspinner");
const builtin = @import("builtin");

const ITERATIONS: u64 = 20_000_000;

fn iterationsFromEnv() u64 {
    if (@hasDecl(std.process, "getEnvMap")) {
        var env_map = std.process.getEnvMap(std.heap.page_allocator) catch return ITERATIONS;
        defer env_map.deinit();

        const env = env_map.get("BENCH_ITERS") orelse return ITERATIONS;
        const parsed = std.fmt.parseInt(u64, env, 10) catch return ITERATIONS;
        return if (parsed == 0) ITERATIONS else parsed;
    }

    if (@hasDecl(std.process, "Environ")) {
        const environ: std.process.Environ = if (builtin.os.tag == .windows)
            .{ .block = .global }
        else
            .{ .block = .empty };

        var env_map = std.process.Environ.createMap(environ, std.heap.page_allocator) catch return ITERATIONS;
        defer env_map.deinit();

        const env = env_map.get("BENCH_ITERS") orelse return ITERATIONS;
        const parsed = std.fmt.parseInt(u64, env, 10) catch return ITERATIONS;
        return if (parsed == 0) ITERATIONS else parsed;
    }

    return ITERATIONS;
}

pub fn main() !void {
    const iterations = iterationsFromEnv();
    const spinner = sp.presets.braille.dots();
    const step_ns = spinner.interval();

    var checksum: u64 = 0;
    var elapsed_ns: u64 = 0;

    for (0..iterations) |_| {
        const frame = spinner.frameAt(elapsed_ns);
        checksum +%= @as(u64, frame[0]);
        elapsed_ns +%= step_ns;
    }

    std.mem.doNotOptimizeAway(checksum);

    std.debug.print("checksum={d}\n", .{checksum});
}
