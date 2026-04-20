const timed = @import("timed.zig");
const ticked = @import("ticked.zig");

pub const Size = @import("size.zig").Size;
pub const util = @import("util.zig");
pub const presets = @import("presets/mod.zig");

pub const TimedSpinner = timed.TimedSpinner;
pub const TickedSpinner = ticked.TickedSpinner;

pub fn Timed(comptime Spec: type) type {
    return timed.TimedSpinner(Spec, false);
}

pub fn Ticked(comptime Spec: type) type {
    return ticked.TickedSpinner(Spec, false);
}

pub fn SpinnerSpec(
    comptime spec_width: usize,
    comptime spec_height: usize,
    comptime spec_interval_ns: u64,
    comptime spec_frames: anytype,
) type {
    return struct {
        pub const width = spec_width;
        pub const height = spec_height;
        pub const interval_ns = if (spec_interval_ns == 0) @as(u64, 1) else spec_interval_ns;
        pub const frames = spec_frames;
    };
}
