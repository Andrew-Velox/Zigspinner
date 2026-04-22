# 🌀 Zigspinner
![Demo](./.github/assets/demo.gif)
<!-- ![Benchmark](https://img.shields.io/badge/benchmark-Zig%20faster%20in%20controlled%20loop-brightgreen)
[![Benchmark CI](https://img.shields.io/github/actions/workflow/status/Andrew-Velox/Zigspinner/benchmark.yml?label=Benchmark%20CI)](https://github.com/Andrew-Velox/Zigspinner/actions/workflows/benchmark.yml) -->

A minimal terminal spinner library for Zig.

Zigspinner is inspired by Rust spinner crates and keeps spinner data compile-time friendly with a small runtime API.

Inspired by the Rust project [rattles](https://github.com/vyfor/rattles) by [vyfor](https://github.com/vyfor).

## Features

- Timed spinners driven by elapsed time
- Ticked spinners for manual/frame-by-frame control
- Reverse direction toggle
- Offset and interval controls
- Preset categories:
  - arrows
  - ascii
  - braille
  - emoji
- Interactive showcase example

## Requirements

- Minimum required: Zig 0.15.2
- Verified working: Zig 0.15.2 and Zig 0.16.0

## Quick Start

### Run locally

```bash
zig build
zig build test
zig build run
zig build run-no-std
zig build run-showcase
```

## Performance

Auto-generated benchmark block (updated by CI on release):

<!-- BENCHMARK:START -->
### Benchmark Snapshot (2026-04-21)

Method:

- Controlled, non-interactive spinner loop
- Same workload in both implementations
- BENCH_ITERS=100000000
- CPU affinity pinned to one core when supported
- 1 warmup + 12 measured runs each

Results (seconds, lower is better):

| Impl | Min | Mean | Median | Max |
|---|---:|---:|---:|---:|
| Rust (rattles) | 0.2557 | 0.2566 | 0.2565 | 0.2580 |
| Zig (Zigspinner) | 0.0847 | 0.0879 | 0.0854 | 0.1108 |

Winner:

- By mean: Zig (65.73% faster)
- By median: Zig (66.72% faster)
<!-- BENCHMARK:END -->



## Use As A Dependency

Add your package in another Zig project:

```bash
zig fetch --save git+https://github.com/Andrew-Velox/Zigspinner.git
```

In the consumer's build script, expose the module:

```zig
const dep = b.dependency("Zigspinner", .{});
const zigspinner_mod = dep.module("Zigspinner");

exe.root_module.addImport("Zigspinner", zigspinner_mod);
```

Then import in code:

```zig
const sp = @import("Zigspinner");
```

## Basic Usage

### Timed spinner (minimal)

```zig
const std = @import("std");
const sp = @import("Zigspinner");

pub fn main() !void {
    var spinner = sp.presets.ascii.simple_dots_scrolling();
    var elapsed: u64 = 0;
    const step_ns: u64 = 30_000_000;

    while (true) {
        std.debug.print("\r{s}", .{spinner.frameAt(elapsed)});

        if (@hasDecl(std.Thread, "sleep")) {
            std.Thread.sleep(step_ns);
        } else {
            _ = std.Thread.yield() catch {};
        }
        elapsed +%= step_ns;
    }
}
```

  ### Timed spinner (Unicode-safe on Windows)

  ```zig
  const std = @import("std");
  const builtin = @import("builtin");
  const sp = @import("Zigspinner");

  fn configureTerminalOutput() void {
      if (builtin.os.tag != .windows) return;

      const win = std.os.windows;
      const SetConsoleOutputCP = @extern(
          *const fn (code_page_id: win.UINT) callconv(.winapi) win.BOOL,
          .{ .name = "SetConsoleOutputCP", .library_name = "kernel32" },
      );
      _ = SetConsoleOutputCP(65001);
  }

  pub fn main() !void {
      configureTerminalOutput();

      var spinner = sp.presets.emoji.moon();
      var elapsed: u64 = 0;
      const step_ns: u64 = 30_000_000;

      while (true) {
          std.debug.print("\r{s}", .{spinner.frameAt(elapsed)});

          if (@hasDecl(std.Thread, "sleep")) {
              std.Thread.sleep(step_ns);
          } else {
              _ = std.Thread.yield() catch {};
          }
          elapsed +%= step_ns;
      }
  }



  ```

### Reverse direction

```zig
const forward = sp.presets.ascii.rolling_line();
const reversed = forward.reverse();
```

### Ticked spinner (manual)

```zig
var ticked = sp.presets.ascii.simple_dots().intoTicked();
_ = ticked.tick();
const frame = ticked.currentFrame();
_ = frame;
```

### No-std style driving (external clock)

```zig
const spinner = sp.presets.ascii.simple_dots_scrolling();
var elapsed_ns: u64 = 0;

for (0..8) |_| {
    _ = spinner.frameAt(elapsed_ns);
    elapsed_ns += spinner.interval();
}
```

## Define A Custom Spinner

```zig
const sp = @import("Zigspinner");

const MySpec = sp.SpinnerSpec(1, 1, 80_000_000, [_][]const []const u8{
    &[_][]const u8{"-"},
    &[_][]const u8{"\\"},
    &[_][]const u8{"|"},
    &[_][]const u8{"/"},
});

const MySpinner = sp.Timed(MySpec);

pub fn buildSpinner() MySpinner {
    return MySpinner.init();
}
```

## Presets Overview

- arrows:
  - arrow
  - double_arrow
- ascii:
  - dqpb
  - rolling_line
  - simple_dots
  - simple_dots_scrolling
  - arc
  - balloon
  - circle_halves
  - circle_quarters
  - point
  - square_corners
  - toggle
  - triangle
  - grow_horizontal
  - grow_vertical
  - noise
- braille:
  - dots, dots2 ... dots14
  - dots_circle
  - sand, bounce, wave, scan, rain
  - pulse, snake, sparkle, cascade, columns
  - orbit, breathe, waverows
  - checkerboard, helix, fillsweep, diagswipe, infinity
- emoji:
  - hearts
  - clock
  - earth
  - moon
  - speaker
  - weather

## Examples

- examples/no_std.zig: external clock and ticked usage
- examples/showcase.zig: full interactive panel showcase
  - q to quit
  - r to reverse direction

## API Surface

Main exports from src/root.zig:

- Size
- TimedSpinner
- TickedSpinner
- Timed(comptime Spec)
- Ticked(comptime Spec)
- SpinnerSpec(...)
- presets

## Notes For Windows Terminal

The bundled executables enable UTF-8 output on Windows automatically.
For your own app code, use `configureTerminalOutput()` when rendering Unicode-heavy presets (emoji/braille).

If Unicode still looks garbled:

- Use a Unicode-capable terminal font (for example Cascadia Mono or JetBrains Mono)
- Keep terminal encoding in UTF-8


