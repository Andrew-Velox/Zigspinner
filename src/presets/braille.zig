const root = @import("../root.zig");

const DotsSpec = root.SpinnerSpec(1, 1, 80_000_000, [_][]const []const u8{ &[_][]const u8{"⠋"}, &[_][]const u8{"⠙"}, &[_][]const u8{"⠹"}, &[_][]const u8{"⠸"}, &[_][]const u8{"⠼"}, &[_][]const u8{"⠴"}, &[_][]const u8{"⠦"}, &[_][]const u8{"⠧"}, &[_][]const u8{"⠇"}, &[_][]const u8{"⠏"} });
const Dots2Spec = root.SpinnerSpec(1, 1, 80_000_000, [_][]const []const u8{ &[_][]const u8{"⣾"}, &[_][]const u8{"⣽"}, &[_][]const u8{"⣻"}, &[_][]const u8{"⢿"}, &[_][]const u8{"⡿"}, &[_][]const u8{"⣟"}, &[_][]const u8{"⣯"}, &[_][]const u8{"⣷"} });
const Dots3Spec = root.SpinnerSpec(1, 1, 80_000_000, [_][]const []const u8{ &[_][]const u8{"⠋"}, &[_][]const u8{"⠙"}, &[_][]const u8{"⠚"}, &[_][]const u8{"⠞"}, &[_][]const u8{"⠖"}, &[_][]const u8{"⠦"} });
const Dots4Spec = root.SpinnerSpec(1, 1, 80_000_000, [_][]const []const u8{ &[_][]const u8{"⠄"}, &[_][]const u8{"⠆"}, &[_][]const u8{"⠇"}, &[_][]const u8{"⠋"}, &[_][]const u8{"⠙"}, &[_][]const u8{"⠸"} });
const Dots5Spec = root.SpinnerSpec(1, 1, 80_000_000, [_][]const []const u8{ &[_][]const u8{"⠋"}, &[_][]const u8{"⠙"}, &[_][]const u8{"⠚"}, &[_][]const u8{"⠒"}, &[_][]const u8{"⠂"}, &[_][]const u8{"⠲"} });
const Dots6Spec = root.SpinnerSpec(1, 1, 80_000_000, [_][]const []const u8{ &[_][]const u8{"⠁"}, &[_][]const u8{"⠉"}, &[_][]const u8{"⠙"}, &[_][]const u8{"⠚"}, &[_][]const u8{"⠒"}, &[_][]const u8{"⠲"} });
const Dots7Spec = root.SpinnerSpec(1, 1, 80_000_000, [_][]const []const u8{ &[_][]const u8{"⠈"}, &[_][]const u8{"⠉"}, &[_][]const u8{"⠋"}, &[_][]const u8{"⠓"}, &[_][]const u8{"⠒"}, &[_][]const u8{"⠦"} });
const Dots8Spec = root.SpinnerSpec(1, 1, 80_000_000, [_][]const []const u8{ &[_][]const u8{"⠁"}, &[_][]const u8{"⠉"}, &[_][]const u8{"⠙"}, &[_][]const u8{"⠚"}, &[_][]const u8{"⠒"}, &[_][]const u8{"⠦"} });
const Dots9Spec = root.SpinnerSpec(1, 1, 80_000_000, [_][]const []const u8{ &[_][]const u8{"⢹"}, &[_][]const u8{"⢺"}, &[_][]const u8{"⢼"}, &[_][]const u8{"⣸"}, &[_][]const u8{"⣇"}, &[_][]const u8{"⡧"} });
const Dots10Spec = root.SpinnerSpec(1, 1, 80_000_000, [_][]const []const u8{ &[_][]const u8{"⢄"}, &[_][]const u8{"⢂"}, &[_][]const u8{"⢁"}, &[_][]const u8{"⡁"}, &[_][]const u8{"⡈"}, &[_][]const u8{"⡐"} });
const Dots11Spec = root.SpinnerSpec(1, 1, 100_000_000, [_][]const []const u8{ &[_][]const u8{"⠁"}, &[_][]const u8{"⠂"}, &[_][]const u8{"⠄"}, &[_][]const u8{"⡀"}, &[_][]const u8{"⢀"}, &[_][]const u8{"⠠"} });
const Dots12Spec = root.SpinnerSpec(2, 1, 80_000_000, [_][]const []const u8{ &[_][]const u8{"⢀⠀"}, &[_][]const u8{"⡀⠀"}, &[_][]const u8{"⠄⠀"}, &[_][]const u8{"⢂⠀"}, &[_][]const u8{"⡂⠀"}, &[_][]const u8{"⠅⠀"} });
const Dots13Spec = root.SpinnerSpec(1, 1, 80_000_000, [_][]const []const u8{ &[_][]const u8{"⣼"}, &[_][]const u8{"⣹"}, &[_][]const u8{"⢻"}, &[_][]const u8{"⠿"}, &[_][]const u8{"⡟"}, &[_][]const u8{"⣏"} });
const Dots14Spec = root.SpinnerSpec(2, 1, 80_000_000, [_][]const []const u8{ &[_][]const u8{"⠉⠉"}, &[_][]const u8{"⠈⠙"}, &[_][]const u8{"⠀⠹"}, &[_][]const u8{"⠀⢸"}, &[_][]const u8{"⠀⣰"}, &[_][]const u8{"⢀⣠"} });

const DotsCircleSpec = root.SpinnerSpec(2, 1, 80_000_000, [_][]const []const u8{ &[_][]const u8{"⢎ "}, &[_][]const u8{"⠎⠁"}, &[_][]const u8{"⠊⠑"}, &[_][]const u8{"⠈⠱"}, &[_][]const u8{" ⡱"}, &[_][]const u8{"⢀⡰"} });
const SandSpec = root.SpinnerSpec(1, 1, 80_000_000, [_][]const []const u8{ &[_][]const u8{"⠁"}, &[_][]const u8{"⠂"}, &[_][]const u8{"⠄"}, &[_][]const u8{"⡀"}, &[_][]const u8{"⣀"}, &[_][]const u8{"⣿"} });
const BounceSpec = root.SpinnerSpec(1, 1, 120_000_000, [_][]const []const u8{ &[_][]const u8{"⠁"}, &[_][]const u8{"⠂"}, &[_][]const u8{"⠄"}, &[_][]const u8{"⡀"}, &[_][]const u8{"⠄"}, &[_][]const u8{"⠂"} });
const WaveSpec = root.SpinnerSpec(4, 1, 100_000_000, [_][]const []const u8{ &[_][]const u8{"⠁⠂⠄⡀"}, &[_][]const u8{"⠂⠄⡀⢀"}, &[_][]const u8{"⠄⡀⢀⠠"}, &[_][]const u8{"⡀⢀⠠⠐"}, &[_][]const u8{"⢀⠠⠐⠈"}, &[_][]const u8{"⠠⠐⠈⠁"} });
const ScanSpec = root.SpinnerSpec(4, 1, 70_000_000, [_][]const []const u8{ &[_][]const u8{"⠀⠀⠀⠀"}, &[_][]const u8{"⡇⠀⠀⠀"}, &[_][]const u8{"⣿⠀⠀⠀"}, &[_][]const u8{"⢸⡇⠀⠀"}, &[_][]const u8{"⠀⣿⠀⠀"}, &[_][]const u8{"⠀⢸⡇⠀"} });
const RainSpec = root.SpinnerSpec(4, 1, 100_000_000, [_][]const []const u8{ &[_][]const u8{"⢁⠂⠔⠈"}, &[_][]const u8{"⠂⠌⡠⠐"}, &[_][]const u8{"⠄⡐⢀⠡"}, &[_][]const u8{"⡈⠠⠀⢂"}, &[_][]const u8{"⠐⢀⠁⠄"}, &[_][]const u8{"⠠⠁⠊⡀"} });
const PulseSpec = root.SpinnerSpec(3, 1, 180_000_000, [_][]const []const u8{ &[_][]const u8{"⠀⠶⠀"}, &[_][]const u8{"⠰⣿⠆"}, &[_][]const u8{"⢾⣉⡷"}, &[_][]const u8{"⣏⠀⣹"}, &[_][]const u8{"⡁⠀⢈"} });
const SnakeSpec = root.SpinnerSpec(2, 1, 80_000_000, [_][]const []const u8{ &[_][]const u8{"⣁⡀"}, &[_][]const u8{"⣉⠀"}, &[_][]const u8{"⡉⠁"}, &[_][]const u8{"⠉⠉"}, &[_][]const u8{"⠈⠙"}, &[_][]const u8{"⠀⠛"} });
const SparkleSpec = root.SpinnerSpec(4, 1, 150_000_000, [_][]const []const u8{ &[_][]const u8{"⡡⠊⢔⠡"}, &[_][]const u8{"⠊⡰⡡⡘"}, &[_][]const u8{"⢔⢅⠈⢢"}, &[_][]const u8{"⡁⢂⠆⡍"}, &[_][]const u8{"⢔⠨⢑⢐"}, &[_][]const u8{"⠨⡑⡠⠊"} });
const CascadeSpec = root.SpinnerSpec(4, 1, 60_000_000, [_][]const []const u8{ &[_][]const u8{"⠀⠀⠀⠀"}, &[_][]const u8{"⠁⠀⠀⠀"}, &[_][]const u8{"⠋⠀⠀⠀"}, &[_][]const u8{"⠞⠁⠀⠀"}, &[_][]const u8{"⡴⠋⠀⠀"}, &[_][]const u8{"⣠⠞⠁⠀"} });
const ColumnsSpec = root.SpinnerSpec(3, 1, 60_000_000, [_][]const []const u8{ &[_][]const u8{"⡀⠀⠀"}, &[_][]const u8{"⡄⠀⠀"}, &[_][]const u8{"⡆⠀⠀"}, &[_][]const u8{"⡇⠀⠀"}, &[_][]const u8{"⣇⠀⠀"}, &[_][]const u8{"⣧⠀⠀"} });
const OrbitSpec = root.SpinnerSpec(1, 1, 100_000_000, [_][]const []const u8{ &[_][]const u8{"⠃"}, &[_][]const u8{"⠉"}, &[_][]const u8{"⠘"}, &[_][]const u8{"⠰"}, &[_][]const u8{"⢠"}, &[_][]const u8{"⣀"} });
const BreatheSpec = root.SpinnerSpec(1, 1, 100_000_000, [_][]const []const u8{ &[_][]const u8{"⠀"}, &[_][]const u8{"⠂"}, &[_][]const u8{"⠌"}, &[_][]const u8{"⡑"}, &[_][]const u8{"⢕"}, &[_][]const u8{"⢝"} });
const WaveRowsSpec = root.SpinnerSpec(4, 1, 90_000_000, [_][]const []const u8{ &[_][]const u8{"⠖⠉⠉⠑"}, &[_][]const u8{"⡠⠖⠉⠉"}, &[_][]const u8{"⣠⡠⠖⠉"}, &[_][]const u8{"⣄⣠⡠⠖"}, &[_][]const u8{"⠢⣄⣠⡠"}, &[_][]const u8{"⠙⠢⣄⣠"} });
const CheckerboardSpec = root.SpinnerSpec(3, 1, 250_000_000, [_][]const []const u8{ &[_][]const u8{"⢕⢕⢕"}, &[_][]const u8{"⡪⡪⡪"}, &[_][]const u8{"⢊⠔⡡"}, &[_][]const u8{"⡡⢊⠔"} });
const HelixSpec = root.SpinnerSpec(4, 1, 80_000_000, [_][]const []const u8{ &[_][]const u8{"⢌⣉⢎⣉"}, &[_][]const u8{"⣉⡱⣉⡱"}, &[_][]const u8{"⣉⢎⣉⢎"}, &[_][]const u8{"⡱⣉⡱⣉"}, &[_][]const u8{"⢎⣉⢎⣉"}, &[_][]const u8{"⣉⡱⣉⡱"} });
const FillSweepSpec = root.SpinnerSpec(2, 1, 100_000_000, [_][]const []const u8{ &[_][]const u8{"⣀⣀"}, &[_][]const u8{"⣤⣤"}, &[_][]const u8{"⣶⣶"}, &[_][]const u8{"⣿⣿"}, &[_][]const u8{"⣶⣶"}, &[_][]const u8{"⣤⣤"} });
const DiagSwipeSpec = root.SpinnerSpec(2, 1, 60_000_000, [_][]const []const u8{ &[_][]const u8{"⠁⠀"}, &[_][]const u8{"⠋⠀"}, &[_][]const u8{"⠟⠁"}, &[_][]const u8{"⡿⠋"}, &[_][]const u8{"⣿⠟"}, &[_][]const u8{"⣿⡿"} });
const InfinitySpec = root.SpinnerSpec(4, 1, 60_000_000, [_][]const []const u8{ &[_][]const u8{"⢎⡱⣉⠆"}, &[_][]const u8{"⢎⡱⣈⠆"}, &[_][]const u8{"⢎⡱⣀⠆"}, &[_][]const u8{"⢎⡱⣀⠄"}, &[_][]const u8{"⢎⡱⣀ "}, &[_][]const u8{"⢎⡱⡀ "} });

pub fn dots() root.Timed(DotsSpec) {
    return root.Timed(DotsSpec).init();
}
pub fn dots2() root.Timed(Dots2Spec) {
    return root.Timed(Dots2Spec).init();
}
pub fn dots3() root.Timed(Dots3Spec) {
    return root.Timed(Dots3Spec).init();
}
pub fn dots4() root.Timed(Dots4Spec) {
    return root.Timed(Dots4Spec).init();
}
pub fn dots5() root.Timed(Dots5Spec) {
    return root.Timed(Dots5Spec).init();
}
pub fn dots6() root.Timed(Dots6Spec) {
    return root.Timed(Dots6Spec).init();
}
pub fn dots7() root.Timed(Dots7Spec) {
    return root.Timed(Dots7Spec).init();
}
pub fn dots8() root.Timed(Dots8Spec) {
    return root.Timed(Dots8Spec).init();
}
pub fn dots9() root.Timed(Dots9Spec) {
    return root.Timed(Dots9Spec).init();
}
pub fn dots10() root.Timed(Dots10Spec) {
    return root.Timed(Dots10Spec).init();
}
pub fn dots11() root.Timed(Dots11Spec) {
    return root.Timed(Dots11Spec).init();
}
pub fn dots12() root.Timed(Dots12Spec) {
    return root.Timed(Dots12Spec).init();
}
pub fn dots13() root.Timed(Dots13Spec) {
    return root.Timed(Dots13Spec).init();
}
pub fn dots14() root.Timed(Dots14Spec) {
    return root.Timed(Dots14Spec).init();
}
pub fn dots_circle() root.Timed(DotsCircleSpec) {
    return root.Timed(DotsCircleSpec).init();
}
pub fn sand() root.Timed(SandSpec) {
    return root.Timed(SandSpec).init();
}
pub fn bounce() root.Timed(BounceSpec) {
    return root.Timed(BounceSpec).init();
}
pub fn wave() root.Timed(WaveSpec) {
    return root.Timed(WaveSpec).init();
}
pub fn scan() root.Timed(ScanSpec) {
    return root.Timed(ScanSpec).init();
}
pub fn rain() root.Timed(RainSpec) {
    return root.Timed(RainSpec).init();
}
pub fn pulse() root.Timed(PulseSpec) {
    return root.Timed(PulseSpec).init();
}
pub fn snake() root.Timed(SnakeSpec) {
    return root.Timed(SnakeSpec).init();
}
pub fn sparkle() root.Timed(SparkleSpec) {
    return root.Timed(SparkleSpec).init();
}
pub fn cascade() root.Timed(CascadeSpec) {
    return root.Timed(CascadeSpec).init();
}
pub fn columns() root.Timed(ColumnsSpec) {
    return root.Timed(ColumnsSpec).init();
}
pub fn orbit() root.Timed(OrbitSpec) {
    return root.Timed(OrbitSpec).init();
}
pub fn breathe() root.Timed(BreatheSpec) {
    return root.Timed(BreatheSpec).init();
}
pub fn waverows() root.Timed(WaveRowsSpec) {
    return root.Timed(WaveRowsSpec).init();
}
pub fn checkerboard() root.Timed(CheckerboardSpec) {
    return root.Timed(CheckerboardSpec).init();
}
pub fn helix() root.Timed(HelixSpec) {
    return root.Timed(HelixSpec).init();
}
pub fn fillsweep() root.Timed(FillSweepSpec) {
    return root.Timed(FillSweepSpec).init();
}
pub fn diagswipe() root.Timed(DiagSwipeSpec) {
    return root.Timed(DiagSwipeSpec).init();
}
pub fn infinity() root.Timed(InfinitySpec) {
    return root.Timed(InfinitySpec).init();
}
