const root = @import("../root.zig");

const DqpbSpec = root.SpinnerSpec(1, 1, 100_000_000, [_][]const []const u8{
    &[_][]const u8{"d"}, &[_][]const u8{"q"}, &[_][]const u8{"p"}, &[_][]const u8{"b"},
});

const RollingLineSpec = root.SpinnerSpec(3, 1, 80_000_000, [_][]const []const u8{
    &[_][]const u8{"/"}, &[_][]const u8{"-"}, &[_][]const u8{"\\"}, &[_][]const u8{"|"}, &[_][]const u8{"\\"}, &[_][]const u8{"-"},
});

const SimpleDotsSpec = root.SpinnerSpec(3, 1, 400_000_000, [_][]const []const u8{
    &[_][]const u8{".  "}, &[_][]const u8{".. "}, &[_][]const u8{"..."}, &[_][]const u8{"   "},
});

const SimpleDotsScrollingSpec = root.SpinnerSpec(3, 1, 200_000_000, [_][]const []const u8{
    &[_][]const u8{".  "}, &[_][]const u8{".. "}, &[_][]const u8{"..."}, &[_][]const u8{" .."}, &[_][]const u8{"  ."}, &[_][]const u8{"   "},
});

const ArcSpec = root.SpinnerSpec(1, 1, 100_000_000, [_][]const []const u8{
    &[_][]const u8{"◜"}, &[_][]const u8{"◠"}, &[_][]const u8{"◝"}, &[_][]const u8{"◞"}, &[_][]const u8{"◡"}, &[_][]const u8{"◟"},
});

const BalloonSpec = root.SpinnerSpec(1, 1, 120_000_000, [_][]const []const u8{
    &[_][]const u8{"."}, &[_][]const u8{"o"}, &[_][]const u8{"O"}, &[_][]const u8{"o"}, &[_][]const u8{"."},
});

const CircleHalvesSpec = root.SpinnerSpec(1, 1, 50_000_000, [_][]const []const u8{
    &[_][]const u8{"◐"}, &[_][]const u8{"◓"}, &[_][]const u8{"◑"}, &[_][]const u8{"◒"},
});

const CircleQuartersSpec = root.SpinnerSpec(1, 1, 120_000_000, [_][]const []const u8{
    &[_][]const u8{"◴"}, &[_][]const u8{"◷"}, &[_][]const u8{"◶"}, &[_][]const u8{"◵"},
});

const PointSpec = root.SpinnerSpec(3, 1, 200_000_000, [_][]const []const u8{
    &[_][]const u8{"···"}, &[_][]const u8{"•··"}, &[_][]const u8{"·•·"}, &[_][]const u8{"··•"}, &[_][]const u8{"···"},
});

const SquareCornersSpec = root.SpinnerSpec(1, 1, 180_000_000, [_][]const []const u8{
    &[_][]const u8{"◰"}, &[_][]const u8{"◳"}, &[_][]const u8{"◲"}, &[_][]const u8{"◱"},
});

const ToggleSpec = root.SpinnerSpec(1, 1, 250_000_000, [_][]const []const u8{
    &[_][]const u8{"⊶"}, &[_][]const u8{"⊷"},
});

const TriangleSpec = root.SpinnerSpec(1, 1, 50_000_000, [_][]const []const u8{
    &[_][]const u8{"◢"}, &[_][]const u8{"◣"}, &[_][]const u8{"◤"}, &[_][]const u8{"◥"},
});

const GrowHorizontalSpec = root.SpinnerSpec(1, 1, 120_000_000, [_][]const []const u8{
    &[_][]const u8{"▏"}, &[_][]const u8{"▎"}, &[_][]const u8{"▍"}, &[_][]const u8{"▌"}, &[_][]const u8{"▋"}, &[_][]const u8{"▊"}, &[_][]const u8{"▉"}, &[_][]const u8{"▊"}, &[_][]const u8{"▋"}, &[_][]const u8{"▌"}, &[_][]const u8{"▍"}, &[_][]const u8{"▎"},
});

const GrowVerticalSpec = root.SpinnerSpec(1, 1, 120_000_000, [_][]const []const u8{
    &[_][]const u8{"▁"}, &[_][]const u8{"▃"}, &[_][]const u8{"▄"}, &[_][]const u8{"▅"}, &[_][]const u8{"▆"}, &[_][]const u8{"▇"}, &[_][]const u8{"▆"}, &[_][]const u8{"▅"}, &[_][]const u8{"▄"}, &[_][]const u8{"▃"},
});

const NoiseSpec = root.SpinnerSpec(1, 1, 100_000_000, [_][]const []const u8{
    &[_][]const u8{"▓"}, &[_][]const u8{"▒"}, &[_][]const u8{"░"}, &[_][]const u8{" "}, &[_][]const u8{"░"}, &[_][]const u8{"▒"},
});

pub fn dqpb() root.Timed(DqpbSpec) {
    return root.Timed(DqpbSpec).init();
}
pub fn rolling_line() root.Timed(RollingLineSpec) {
    return root.Timed(RollingLineSpec).init();
}
pub fn simple_dots() root.Timed(SimpleDotsSpec) {
    return root.Timed(SimpleDotsSpec).init();
}
pub fn simple_dots_scrolling() root.Timed(SimpleDotsScrollingSpec) {
    return root.Timed(SimpleDotsScrollingSpec).init();
}
pub fn arc() root.Timed(ArcSpec) {
    return root.Timed(ArcSpec).init();
}
pub fn balloon() root.Timed(BalloonSpec) {
    return root.Timed(BalloonSpec).init();
}
pub fn circle_halves() root.Timed(CircleHalvesSpec) {
    return root.Timed(CircleHalvesSpec).init();
}
pub fn circle_quarters() root.Timed(CircleQuartersSpec) {
    return root.Timed(CircleQuartersSpec).init();
}
pub fn point() root.Timed(PointSpec) {
    return root.Timed(PointSpec).init();
}
pub fn square_corners() root.Timed(SquareCornersSpec) {
    return root.Timed(SquareCornersSpec).init();
}
pub fn toggle() root.Timed(ToggleSpec) {
    return root.Timed(ToggleSpec).init();
}
pub fn triangle() root.Timed(TriangleSpec) {
    return root.Timed(TriangleSpec).init();
}
pub fn grow_horizontal() root.Timed(GrowHorizontalSpec) {
    return root.Timed(GrowHorizontalSpec).init();
}
pub fn grow_vertical() root.Timed(GrowVerticalSpec) {
    return root.Timed(GrowVerticalSpec).init();
}
pub fn noise() root.Timed(NoiseSpec) {
    return root.Timed(NoiseSpec).init();
}
