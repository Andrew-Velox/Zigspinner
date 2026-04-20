const std = @import("std");
const util = @import("util.zig");
const Size = @import("size.zig").Size;
const ticked = @import("ticked.zig");

const empty_frame_lines = [_][]const u8{};
const empty_frame: []const u8 = "";

pub fn TimedSpinner(comptime Spec: type, comptime reversed: bool) type {
    return struct {
        const Self = @This();

        interval_ns: u64,
        offset_value: usize,

        pub fn init() Self {
            return .{
                .interval_ns = defaultInterval(),
                .offset_value = 0,
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

        pub fn frames(self: Self, index: usize) []const []const u8 {
            const l = self.len();
            if (l == 0) return empty_frame_lines[0..];

            const shifted = (index + self.offset_value) % l;
            const idx = util.applyDirection(shifted, l, reversed);
            return Spec.frames[idx];
        }

        pub fn frame(self: Self, index: usize) []const u8 {
            const lines = self.frames(index);
            if (lines.len == 0) return empty_frame;
            return lines[0];
        }

        pub fn indexAt(self: Self, elapsed_ns: u64) usize {
            const l = self.len();
            if (l == 0) return 0;

            const base = util.frameAt(elapsed_ns, self.interval_ns, l);
            const shifted = (base + self.offset_value) % l;
            return util.applyDirection(shifted, l, reversed);
        }

        pub fn framesAt(self: Self, elapsed_ns: u64) []const []const u8 {
            const idx = self.indexAt(elapsed_ns);
            return Spec.frames[idx];
        }

        pub fn frameAt(self: Self, elapsed_ns: u64) []const u8 {
            const lines = self.framesAt(elapsed_ns);
            if (lines.len == 0) return empty_frame;
            return lines[0];
        }

        pub fn setInterval(self: Self, interval_ns: u64) Self {
            var copy = self;
            copy.interval_ns = if (interval_ns == 0) 1 else interval_ns;
            return copy;
        }

        pub fn offset(self: Self, offset_value: usize) Self {
            var copy = self;
            copy.offset_value = normalizeOffset(offset_value);
            return copy;
        }

        pub fn reverse(self: Self) TimedSpinner(Spec, !reversed) {
            return .{
                .interval_ns = self.interval_ns,
                .offset_value = self.offset_value,
            };
        }

        pub fn intoTicked(self: Self) ticked.TickedSpinner(Spec, reversed) {
            return .{
                .interval_ns = self.interval_ns,
                .offset_value = self.offset_value,
                .current = 0,
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

test "timed spinner index, offset, reverse" {
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

    const Fwd = TimedSpinner(DotSpec, false);

    const f = Fwd.init();
    try std.testing.expectEqual(@as(usize, 4), f.len());
    try std.testing.expectEqualStrings("-", f.frameAt(0));
    try std.testing.expectEqualStrings("\\", f.frameAt(80));
    try std.testing.expectEqualStrings("|", f.frameAt(160));

    const fo = f.offset(1);
    try std.testing.expectEqualStrings("\\", fo.frameAt(0));

    const r = fo.reverse();
    try std.testing.expectEqualStrings("|", r.frameAt(0));
}
