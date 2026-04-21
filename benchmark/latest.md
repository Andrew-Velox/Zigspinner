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