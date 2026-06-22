# PHT Associativity Sweep

This directory contains an automated sweep used to estimate how many probe branch PCs can be simultaneously captured by the Apple M1 Firestorm conditional branch predictor for a selected PHRT/PHR position.

The test is not a direct architectural disclosure of the PHT structure. It is an operational associativity-style probe: for each injected history position, increase the number of unique probe branches and observe when the `rc5` misprediction count jumps above a chosen threshold.

## High-level idea

For each sweep point:

1. Generate an assembly test case with a selected `inject_after` position and a selected number of active probe branches.
2. Build the generated assembly into `pht_tb_auto`.
3. Pin execution to one Firestorm core.
4. Measure `apple_firestorm_pmu/rc5/` using `perf stat`.
5. Record the raw `rc5` count in a CSV.

The random bit `k` is injected into the branch-history setup at different PHRT positions. The test then calls `branch1`, `branch2`, ..., `branchN`, where the probe branch PCs are intentionally close together. As `N` increases, the test checks how many probe branches remain below the misprediction cutoff.

The summary metric is:

```text
max_captured_branches = largest N whose rc5 remains <= cutoff
```

In the uploaded result set, the cutoff used for plotting is `60000`.

## Files

| File | Purpose |
|---|---|
| `gen_tb_assoc.py` | Generates `tb_auto.S` for one `(inject_after, nbranches)` configuration. |
| `sweep_assoc.py` | Runs the full sweep: generate assembly, build, run `perf`, and write raw CSV results. |
| `plot_assoc_sweep.py` | Converts raw sweep results into summary CSV and plots. |
| `linker.ld` | Linker script used to place generated sections at controlled addresses. |
| `tb_auto.S` | Generated assembly for the most recent sweep point. This file is overwritten by the sweep. |
| `pht_tb_auto` | Generated binary. This file is overwritten by the sweep. |
| `assoc_sweep_zero_phrb.csv` | Raw uploaded sweep data. |
| `assoc_sweep_zero_phrb_captured.csv` | Processed summary data: max captured branches per PHRT position. |
| `assoc_sweep_zero_phrb_captured.png` | Summary plot of max captured branches vs PHRT position. |
| `assoc_sweep_zero_phrb_raw_scatter.png` | Raw `rc5` scatter plot across PHRT position and branch count. |

## Requirements

This experiment is intended for an Apple M1 / Firestorm Linux environment with access to Apple PMU events.

Required tools:

```bash
gcc
perf
taskset
python3
pandas
matplotlib
```

The commands below assume core `4` is a Firestorm performance core.

## Generate one test case manually

To generate one assembly test with a specific injection position and number of probe branches:

```bash
python3 gen_tb_assoc.py \
    --inject-after 50 \
    --nbranches 6 \
    --max-branches 8 \
    --total-labels 99 \
    --zero-phrb \
    -o tb_auto.S
```

Then build and measure it:

```bash
gcc -nostdlib -nostartfiles -ffreestanding \
    -fno-pie -no-pie \
    -Wl,-Tlinker.ld \
    -Wl,--build-id=none \
    -o pht_tb_auto tb_auto.S

taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ ./pht_tb_auto
```

Optional symbol check:

```bash
nm -n pht_tb_auto | grep -E '(_start|func_set_phr|branch1|branch2|branch3|branch4|branch5|branch6|branch7|branch8)'
```

## Run the full sweep

The uploaded data appears to use the zero-PHRB mode with `nbranches = 1..8` and `inject_after = 0..98`:

```bash
python3 sweep_assoc.py \
    --inject-start 0 \
    --inject-end 98 \
    --max-branches 8 \
    --total-labels 99 \
    --linker linker.ld \
    --gen ./gen_tb_assoc.py \
    --out assoc_sweep_zero_phrb.csv \
    --cpu 4 \
    --zero-phrb
```

The output CSV has this schema:

```csv
inject_after,phr_pos,nbranches,rc5
```

Column meanings:

| Column | Meaning |
|---|---|
| `inject_after` | Position in the generated PHR setup after which `k` is injected. |
| `phr_pos` | Derived PHRT position used for plotting. In this script, `phr_pos = total_labels - inject_after`. |
| `nbranches` | Number of active probe branches called after setting the history. |
| `rc5` | Raw Firestorm PMU `rc5` misprediction count reported by `perf`. |

## Plot the results

To reproduce the processed CSV and plots:

```bash
python3 plot_assoc_sweep.py \
    assoc_sweep_zero_phrb.csv \
    --cutoff 60000 \
    --out-prefix assoc_sweep_zero_phrb
```

This writes:

```text
assoc_sweep_zero_phrb_captured.csv
assoc_sweep_zero_phrb_captured.png
assoc_sweep_zero_phrb_raw_lines.png
assoc_sweep_zero_phrb_raw_scatter.png
```

The processed CSV has this schema:

```csv
inject_after,phr_pos,max_captured_branches,baseline,cutoff
```

## How to interpret the plots

### Raw scatter / raw lines

The raw plots show `rc5` as a function of:

- PHRT position of `k`
- number of unique probe branches

For a fixed PHRT position, start at `nbranches = 1` and increase `nbranches`. When the `rc5` count stays near the baseline, that branch count is treated as captured. When `rc5` jumps above the cutoff, the test treats the extra branch as exceeding the captured set for that position.

### Captured-branches summary

The captured summary plot reports the largest `nbranches` value whose raw `rc5` remains at or below the cutoff.

Using the uploaded `assoc_sweep_zero_phrb.csv` with cutoff `60000`, the observed `max_captured_branches` values range from `1` to `6` over PHRT positions `1..99`.

Observed pattern in the uploaded data:

- Low PHRT positions near `1..4` capture only about `1` probe branch.
- Many middle positions capture around `4..6` probe branches.
- High PHRT positions near the left side of the plot are mostly around `2..4` captured branches.

This suggests that the effective number of probe branches that can be made to collide/capture in this setup is position-dependent, rather than a single constant across all PHRT positions.

## Zero-PHRB mode

The `--zero-phrb` mode tries to isolate PHRT behavior by reducing PHRB variation:

- dummy branch PCs in `func_set_phr` are 64-byte aligned;
- the injected `b.eq` and `b.ne` branch PCs are also aligned;
- `.L0_inject` and `.L1_inject` targets are 4 bytes apart, so the target bit can differ with `k`;
- the injected path falls through into the next dummy label.

This is why the uploaded result files are named `assoc_sweep_zero_phrb.*`.

## Important cautions

- `max_captured_branches` is threshold-based. Changing `--cutoff` can change the inferred number.
- This is an empirical associativity-style probe, not a direct measurement of a documented PHT way count.
- `rc5` is raw PMU data, so repeatability can depend on core pinning, background noise, PMU permissions, kernel configuration, and exact binary layout.
- `tb_auto.S` and `pht_tb_auto` are generated files and will be overwritten by the sweep.
- The sweep can take a while because it builds and runs one binary for every `(inject_after, nbranches)` pair.

## Troubleshooting

If `perf` fails or reports `<not supported>`, check that the system exposes the Apple Firestorm PMU event:

```bash
perf list | grep -i firestorm
```

If the sweep cannot parse `rc5`, inspect the actual `perf stat` output. Some systems print the event as `apple_firestorm_pmu/rc5/u` even when the command uses `apple_firestorm_pmu/rc5/`.

If the result is noisy, rerun a small region multiple times, keep the machine idle, and pin to the same Firestorm core.
