### Benchmark Snapshot (2026-04-21)

Mode: Zig-only (Rust baseline not found in this checkout)

Method:

- Controlled, non-interactive spinner loop
- BENCH_ITERS=1000000
- CPU affinity pinned to one core when supported
- 1 warmup + 2 measured runs
- Note: CPU pinning failed on at least one run; timing still completed

Results (seconds, lower is better):

| Impl | Min | Mean | Median | Max |
|---|---:|---:|---:|---:|
| Zig (Zigspinner) | 0.0054 | 0.0067 | 0.0067 | 0.0079 |

To enable cross-language comparison, run with a valid Rust benchmark executable path using -RustExe.