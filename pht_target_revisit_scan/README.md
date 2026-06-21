# pht_target_revisit_scan

This folder contains an Apple M1 / Firestorm branch-predictor microbenchmark that revisits a conditional branch after a controllable number of intervening unconditional branch targets. It is used to scan whether changing the target-address alignment and the number of intervening branch targets changes the `rc5` PMU count, which is treated here as the conditional branch misprediction counter.

## Files

| File | Purpose |
|---|---|
| `tb.S` | Single hand-written AArch64 test binary. It clears predictor history, trains a conditional branch, executes a chain of unconditional jumps, then executes a test conditional branch. |
| `linker.ld` | Places code sections at fixed addresses: `.text.init` at `0x380000`, `.text.main` at `0x400000`, and `.text.uncond_jumps` at `0x600000`. This keeps branch locations stable across builds. |
| `script.txt` | Manual build/run recipe for `tb.S`. |
| `sweep_firestorm_target_bits.py` | Main sweep driver. It generates many `tb_*.S` variants with different `.p2align` values and different numbers of unconditional jumps, builds each one, runs it under `perf`, and writes a CSV plus heatmap. |
| `replot_corrected_results.py` | Post-processing script for an existing `results.csv`. It adds a corrected dummy-branch count and computes a baseline-subtracted misprediction-per-iteration value. |

## What the test varies

The sweep has two main knobs:

- `align_bits`: the `.p2align` value shared by the clear branch, training branch, and nearby target label. Larger values force the relevant branch/target addresses to share more low address bits.
- `num_jumps`: the number of unconditional jumps inserted between the trained branch and the test branch.

The default sweep range is:

```bash
align_bits = 2..19
num_jumps  = 67..100
```

The generated assembly loop uses `LOOP_ITERS = 1000000` iterations.

## Requirements

Run this on the target Apple M1 / Firestorm Linux environment where the Apple PMU event is available.

Required tools:

- `gcc`
- `perf`
- `taskset`
- Python 3
- Python packages: `matplotlib`, `numpy`, and for corrected replotting also `pandas`

The default PMU event is:

```bash
apple_firestorm_pmu/rc5/
```

The default core is core `4`.

## Manual single test

Build and inspect the fixed `tb.S` test:

```bash
gcc -nostdlib -nostartfiles -ffreestanding -fno-pie -no-pie \
    -Wl,-Tlinker.ld -Wl,--build-id=none \
    -o tb tb.S

nm -n tb | grep -E '(_start|L_target_clear|L_jump_clear|Train_Branch|Label_Test1|Label_Test2|lbl_tr|lbl_ts1|lbl_ts2)'
```

Run it on Firestorm core 4 and count `rc5`:

```bash
taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ ./tb
```

## Full sweep

Run the default sweep:

```bash
python3 sweep_firestorm_target_bits.py \
    --linker linker.ld \
    --core 4 \
    --event apple_firestorm_pmu/rc5/ \
    --outdir sweep_out
```

This generates:

```text
sweep_out/
├── asm/                 # generated assembly variants
├── results.csv          # raw sweep results
└── heatmap.png          # rc5 / iteration heatmap
```

By default, temporary binaries are deleted after each run. To keep them:

```bash
python3 sweep_firestorm_target_bits.py --linker linker.ld --keep-binaries
```

To extend the jump sweep through 101:

```bash
python3 sweep_firestorm_target_bits.py --linker linker.ld --jump-max 101
```

Useful options:

```text
--align-min N       minimum .p2align value, default 2
--align-max N       maximum .p2align value, default 19
--jump-min N        minimum unconditional jump count, default 67
--jump-max N        maximum unconditional jump count, default 100
--loop-iters N      normalization value for rc5_per_iter label, default 1000000
--core N            CPU core passed to taskset, default 4
--event EVENT       perf event, default apple_firestorm_pmu/rc5/
--outdir DIR        output directory, default sweep_out
--keep-binaries     keep generated binaries in sweep_out/bin/
```

## Corrected replot

After a sweep, generate a baseline-subtracted CSV and heatmap:

```bash
python3 replot_corrected_results.py sweep_out/results.csv \
    --base-rc5 150000 \
    --iters 1000000 \
    --out-csv sweep_out/corrected_results.csv \
    --out-png sweep_out/corrected_heatmap.png
```

This adds:

- `dummy_branches_corrected = num_jumps + 2`
- `mispred_per_iter = (rc5 - base_rc5) / iters`

Note: `replot_corrected_results.py` currently defaults to `--iters 100000`, but the sweep-generated assembly uses `LOOP_ITERS = 1000000`. Pass `--iters 1000000` for this folder unless you intentionally changed the benchmark iteration count.

## Interpretation

Read the heatmap as a scan over possible interactions between branch/target address alignment and intervening unconditional branch targets. Higher `rc5_per_iter` or `mispred_per_iter` regions indicate parameter combinations that caused more conditional branch mispredictions under this benchmark. Treat these as experimental evidence rather than a complete predictor model, since PMU behavior, code placement, core affinity, and unrelated predictor state can affect the counts.
