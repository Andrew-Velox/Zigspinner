const root = @import("../root.zig");

const ArrowSpec = root.SpinnerSpec(1, 1, 100_000_000, [_][]const []const u8{
    &[_][]const u8{"←"},
    &[_][]const u8{"↖"},
    &[_][]const u8{"↑"},
    &[_][]const u8{"↗"},
    &[_][]const u8{"→"},
    &[_][]const u8{"↘"},
    &[_][]const u8{"↓"},
    &[_][]const u8{"↙"},
});

const DoubleArrowSpec = root.SpinnerSpec(1, 1, 100_000_000, [_][]const []const u8{
    &[_][]const u8{"⇐"},
    &[_][]const u8{"⇖"},
    &[_][]const u8{"⇑"},
    &[_][]const u8{"⇗"},
    &[_][]const u8{"⇒"},
    &[_][]const u8{"⇘"},
    &[_][]const u8{"⇓"},
    &[_][]const u8{"⇙"},
});

pub fn arrow() root.Timed(ArrowSpec) {
    return root.Timed(ArrowSpec).init();
}

pub fn double_arrow() root.Timed(DoubleArrowSpec) {
    return root.Timed(DoubleArrowSpec).init();
}
