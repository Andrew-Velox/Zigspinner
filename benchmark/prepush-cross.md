### Benchmark Snapshot (2026-04-21)

Method:

- Controlled, non-interactive spinner loop
- Same workload in both implementations
- BENCH_ITERS=1000000
- CPU affinity pinned to one core when supported
- 1 warmup + 2 measured runs each
- Note: CPU pinning failed on at least one run; timing still completed

Results (seconds, lower is better):

| Impl | Min | Mean | Median | Max |
|---|---:|---:|---:|---:|
| Rust (rattles) | 0.0068 | 0.0069 | 0.0069 | 0.0070 |
| Zig (Zigspinner) | 0.0050 | 0.0062 | 0.0062 | 0.0073 |

Winner:

- By mean: Zig (10.97% faster)
- By median: Zig (10.97% faster)