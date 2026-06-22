# Apple M1 Conditional Branch Predictor Reverse Engineering

This repository is a collection of AArch64 microbenchmarks for studying the Apple M1 / Firestorm conditional branch predictor. The goal is to infer parts of the predictor behavior from controlled experiments rather than from official documentation.

The project focuses on questions such as:

- How long the effective branch history is
- Whether taken, not-taken, unconditional, and indirect branches update the history state
- How branch PC bits and target bits appear to influence prediction-table indexing
- When two branches collide in the same predictor entry
- How many branch entries can be captured before aliasing or replacement effects appear

The main write-up is in [`Apple BP research.pdf`](Apple%20BP%20research.pdf). The folders in this repo contain the raw experiments, scripts, generated assembly, plots, and notes used to support that write-up.

## Environment

These tests were developed and run on Apple Silicon under Asahi Linux, using Linux `perf` to read Apple PMU events. Most measurements pin execution to one Firestorm performance core and count:

```bash
apple_firestorm_pmu/rc5/
```

In this repo, `rc5` is treated as the main conditional-branch misprediction-related counter. Exact PMU semantics are platform-specific, so the important signal is usually the relative change across controlled experiments rather than a single absolute number.

Typical tools used:

- Asahi Linux on Apple M1
- AArch64 assembly
- `gcc`, GNU assembler, and linker scripts
- `taskset` for CPU pinning
- Linux `perf stat` / `perf record`
- Python scripts for sweeps and plotting

## Basic workflow

Most experiment folders follow the same pattern:

1. Generate or edit an AArch64 microbenchmark.
2. Build it with `gcc`, often using a custom linker script to control code placement.
3. Pin the benchmark to a selected core.
4. Measure `apple_firestorm_pmu/rc5/` with `perf stat`.
5. Optionally use `perf record` to locate which branch site caused the events.
6. Sweep one variable at a time and plot the result.

A typical command looks like:

```bash
taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ ./benchmark
```

Some tests use linker scripts to place branch sites or indirect targets at controlled relative addresses. This is important because many experiments depend on changing one PC or target bit while keeping the rest of the branch history as stable as possible.

## Repository structure

The repo is organized as small independent experiments. Each folder is intentionally narrow and usually tests one hypothesis.

| Folder | Purpose |
| --- | --- |
| `ghr_tests/` | Early global-history / train-test correlation experiments. |
| `phr_length/` | Measures how many intervening taken branches can separate an injected history bit from a later probe. |
| `phr_length_NT/` | Similar to `phr_length`, but using not-taken dummy branches to test whether not-taken branches participate in history. |
| `phr_target/` | Tests whether indirect target information contributes to the history used by later conditional branches. |
| `phr_target_indirect/` | Revisit of target-history behavior using linker-controlled indirect targets. |
| `phr_target_revisit*` | Follow-up target-history experiments with more controlled branch placement and comparison plots. |
| `phr_shift_branch/` | Tests which branch PC / target bits affect the history footprint by shifting injected branch sites. |
| `phr_shift_branch_revisit/` | Smaller manual revisit of the shift-branch idea. |
| `pht_*` folders | Experiments for PHT indexing, aliasing, associativity, PC-bit participation, and collision behavior. |
| `linker_pad/` | Linker-script experiments for placing code sections at exact addresses. |
| `pmc_tests/` | Small PMU sanity checks and branch-pattern validation tests. |

Many folders have their own `README.md` with more detailed build/run notes. This top-level README is only meant to explain the overall project.

## How to interpret the experiments

Most tests create two or more branches whose outcomes are tied to the same random bit `k`. The benchmark then manipulates the branch history or PC layout and checks whether a later probe branch is predicted correctly.

The rough interpretation is:

```text
low rc5      -> predictor still distinguishes the useful history / entry
high rc5     -> history was lost, overwritten, aliased, or collided
sharp jump   -> likely boundary where a bit, history position, or associativity limit starts mattering
```

For collision-style PHT experiments:

```text
high rc5  -> branches likely fight in the same predictor entry
low rc5   -> branches likely map to different entries or the history separates them
```

For PHR-length experiments:

```text
low rc5 before threshold   -> injected history bit still influences prediction
~0.5 miss/iter after jump  -> injected history bit is no longer visible to the probe
```

These are empirical interpretations. They are useful for reverse engineering, but they are not official statements about Apple hardware.

## Notes and caveats

- Run on an isolated core when possible. Most scripts use `taskset -c 4` for Firestorm.
- Repeat measurements when a result is close to a threshold.
- Keep build flags, branch alignment, linker scripts, and CPU core fixed when comparing two runs.
- Generated binaries, `perf.data`, and raw sweep outputs are usually not source files and do not need to be committed unless they document a specific result.
- Some folders are manual scratch experiments. Prefer the local folder README when reproducing an individual test.

## Status

This repository is a research artifact rather than a polished benchmark framework. The important pieces are the assembly patterns, controlled placement, perf measurements, and plots that together support the Apple M1 branch predictor reverse-engineering write-up.
