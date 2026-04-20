const std = @import("std");

pub fn applyDirection(index: usize, len: usize, reversed: bool) usize {
    if (len == 0) return 0;
    if (reversed) return (len - 1) - index;
    return index;
}

pub fn frameAt(elapsed_ns: u64, interval_ns: u64, len: usize) usize {
    if (len == 0) return 0;
    const safe_interval = if (interval_ns == 0) @as(u64, 1) else interval_ns;
    return @as(usize, @intCast((elapsed_ns / safe_interval) % len));
}

test "applyDirection forward and reverse" {
    try std.testing.expectEqual(@as(usize, 2), applyDirection(2, 5, false));
    try std.testing.expectEqual(@as(usize, 2), applyDirection(2, 5, true));
    try std.testing.expectEqual(@as(usize, 0), applyDirection(0, 0, true));
}

test "frameAt handles wrapping and zero interval" {
    try std.testing.expectEqual(@as(usize, 0), frameAt(0, 80, 10));
    try std.testing.expectEqual(@as(usize, 3), frameAt(240, 80, 10));
    try std.testing.expectEqual(@as(usize, 1), frameAt(11, 10, 2));
    try std.testing.expectEqual(@as(usize, 0), frameAt(100, 0, 4));
    try std.testing.expectEqual(@as(usize, 0), frameAt(100, 80, 0));
}
