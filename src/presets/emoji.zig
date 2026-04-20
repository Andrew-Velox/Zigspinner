const root = @import("../root.zig");

const ClockSpec = root.SpinnerSpec(1, 1, 100_000_000, [_][]const []const u8{
    &[_][]const u8{"🕛"},
    &[_][]const u8{"🕐"},
    &[_][]const u8{"🕑"},
    &[_][]const u8{"🕒"},
    &[_][]const u8{"🕓"},
    &[_][]const u8{"🕔"},
    &[_][]const u8{"🕕"},
    &[_][]const u8{"🕖"},
    &[_][]const u8{"🕗"},
    &[_][]const u8{"🕘"},
    &[_][]const u8{"🕙"},
    &[_][]const u8{"🕚"},
});

const MoonSpec = root.SpinnerSpec(1, 1, 80_000_000, [_][]const []const u8{
    &[_][]const u8{"🌑"},
    &[_][]const u8{"🌒"},
    &[_][]const u8{"🌓"},
    &[_][]const u8{"🌔"},
    &[_][]const u8{"🌕"},
    &[_][]const u8{"🌖"},
    &[_][]const u8{"🌗"},
    &[_][]const u8{"🌘"},
});

const EarthSpec = root.SpinnerSpec(1, 1, 180_000_000, [_][]const []const u8{
    &[_][]const u8{"🌍"},
    &[_][]const u8{"🌎"},
    &[_][]const u8{"🌏"},
});

const HeartsSpec = root.SpinnerSpec(1, 1, 120_000_000, [_][]const []const u8{
    &[_][]const u8{"🩷"},
    &[_][]const u8{"🧡"},
    &[_][]const u8{"💛"},
    &[_][]const u8{"💚"},
    &[_][]const u8{"💙"},
    &[_][]const u8{"🩵"},
    &[_][]const u8{"💜"},
    &[_][]const u8{"🤎"},
    &[_][]const u8{"🖤"},
    &[_][]const u8{"🩶"},
    &[_][]const u8{"🤍"},
});

const SpeakerSpec = root.SpinnerSpec(1, 1, 160_000_000, [_][]const []const u8{
    &[_][]const u8{"🔈"}, &[_][]const u8{"🔉"}, &[_][]const u8{"🔊"}, &[_][]const u8{"🔉"},
});

const WeatherSpec = root.SpinnerSpec(1, 1, 100_000_000, [_][]const []const u8{
    &[_][]const u8{"☀️"}, &[_][]const u8{"🌤"}, &[_][]const u8{"⛅️"}, &[_][]const u8{"🌥"}, &[_][]const u8{"☁️"}, &[_][]const u8{"🌧"}, &[_][]const u8{"🌨"}, &[_][]const u8{"⛈"},
});

pub fn clock() root.Timed(ClockSpec) {
    return root.Timed(ClockSpec).init();
}

pub fn moon() root.Timed(MoonSpec) {
    return root.Timed(MoonSpec).init();
}

pub fn earth() root.Timed(EarthSpec) {
    return root.Timed(EarthSpec).init();
}

pub fn hearts() root.Timed(HeartsSpec) {
    return root.Timed(HeartsSpec).init();
}

pub fn speaker() root.Timed(SpeakerSpec) {
    return root.Timed(SpeakerSpec).init();
}

pub fn weather() root.Timed(WeatherSpec) {
    return root.Timed(WeatherSpec).init();
}
