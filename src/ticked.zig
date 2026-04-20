const std = @import("std");
const util = @import("util.zig");
const Size = @import("size.zig").Size;
const timed = @import("timed.zig");

const empty_frame_lines = [_][]const u8{};
const empty_frame: []const u8 = "";

pub fn TickedSpinner(comptime Spec: type, comptime reversed: bool) type {
    return struct {
        const Self = @This();

        interval_ns: u64,
        offset_value: usize,
        current: usize,

        pub fn init() Self {
            return .{
                .interval_ns = defaultInterval(),
                .offset_value = 0,
                .current = 0,
            };
        }

        pub fn withOffset(offset_index: usize) Self {
            var s = Self.init();
            s.offset_value = normalizeOffset(offset_index);
            return s;
        }

        pub fn size(self: Self) Size {
            _ = self;
            return Size.init(Spec.width, Spec.height);
        }

        pub fn len(self: Self) usize {
            _ = self;
            return Spec.frames.len;
        }

        pub fn isEmpty(self: Self) bool {
            return self.len() == 0;
        }

        pub fn isReversed(self: Self) bool {
            _ = self;
            return reversed;
        }

        pub fn interval(self: Self) u64 {
            return self.interval_ns;
        }

        pub fn index(self: Self) usize {
            const l = self.len();
            if (l == 0) return 0;
            const shifted = (self.current + self.offset_value) % l;
            return util.applyDirection(shifted, l, reversed);
        }

        pub fn currentFrames(self: Self) []const []const u8 {
            const l = self.len();
            if (l == 0) return empty_frame_lines[0..];
            return Spec.frames[self.index()];
        }

        pub fn currentFrame(self: Self) []const u8 {
            const lines = self.currentFrames();
            if (lines.len == 0) return empty_frame;
            return lines[0];
        }

        pub fn tick(self: *Self) []const []const u8 {
            const l = self.len();
            if (l == 0) return empty_frame_lines[0..];
            self.current = (self.current + 1) % l;
            return self.currentFrames();
        }

        pub fn tickBy(self: *Self, steps: usize) []const []const u8 {
            const l = self.len();
            if (l == 0) return empty_frame_lines[0..];
            self.current = (self.current + (steps % l)) % l;
            return self.currentFrames();
        }

        pub fn reset(self: *Self) void {
            self.current = 0;
        }

        pub fn setInterval(self: Self, new_interval_ns: u64) Self {
            var copy = self;
            copy.interval_ns = if (new_interval_ns == 0) 1 else new_interval_ns;
            return copy;
        }

        pub fn offset(self: Self, new_offset: usize) Self {
            var copy = self;
            copy.offset_value = normalizeOffset(new_offset);
            return copy;
        }

        pub fn reverse(self: Self) TickedSpinner(Spec, !reversed) {
            return .{
                .interval_ns = self.interval_ns,
                .offset_value = self.offset_value,
                .current = self.current,
            };
        }

        pub fn intoTimed(self: Self) timed.TimedSpinner(Spec, reversed) {
            return .{
                .interval_ns = self.interval_ns,
                .offset_value = self.offset_value,
            };
        }

        fn defaultInterval() u64 {
            if (@hasDecl(Spec, "interval_ns")) {
                const v: u64 = Spec.interval_ns;
                return if (v == 0) 1 else v;
            }
            return 80_000_000;
        }

        fn normalizeOffset(offset_index: usize) usize {
            const l = Spec.frames.len;
            if (l == 0) return 0;
            return offset_index % l;
        }
    };
}

test "ticked spinner tick and reverse" {
    const DotSpec = struct {
        pub const width: usize = 1;
        pub const height: usize = 1;
        pub const interval_ns: u64 = 80;
        pub const frames = [_][]const []const u8{
            &[_][]const u8{"-"},
            &[_][]const u8{"\\"},
            &[_][]const u8{"|"},
            &[_][]const u8{"/"},
        };
    };

    const T = TickedSpinner(DotSpec, false);

    var t = T.init();
    try std.testing.expectEqualStrings("-", t.currentFrame());
    _ = t.tick();
    try std.testing.expectEqualStrings("\\", t.currentFrame());
    _ = t.tickBy(2);
    try std.testing.expectEqualStrings("/", t.currentFrame());

    const r = t.reverse();
    try std.testing.expectEqualStrings("-", r.currentFrame());
}
