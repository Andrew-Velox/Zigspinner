const std = @import("std");
const sp = @import("Zigspinner");

const ITERATIONS: u64 = 20_000_000;

fn iterationsFromEnv() u64 {
    const env = std.process.getEnvVarOwned(std.heap.page_allocator, "BENCH_ITERS") catch return ITERATIONS;
    defer std.heap.page_allocator.free(env);

    const parsed = std.fmt.parseInt(u64, env, 10) catch return ITERATIONS;
    return if (parsed == 0) ITERATIONS else parsed;
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

    var stdout_buffer: [256]u8 = undefined;
    var writer = std.fs.File.stdout().writer(&stdout_buffer);
    const out = &writer.interface;
    try out.print("checksum={d}\n", .{checksum});
    try out.flush();
}
