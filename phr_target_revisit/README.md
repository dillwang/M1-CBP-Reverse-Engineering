# PHR Target Revisit - Conditional-Branch Distance Test

This folder contains a manual Apple M1 Firestorm branch-predictor microbenchmark used to test whether a conditional branch can reintroduce or preserve target-history information in the PHR/PHRT state and whether that state affects a later probe branch.

The experiment compares two cases across several controlled relative distances:

- **With test branch**: run the benchmark with the extra conditional test/probe branch enabled.
- **Without test branch**: run the corresponding control case without the extra test/probe effect.

The measured counter is `apple_firestorm_pmu/rc5/`, used here as the branch-misprediction-like event for this reverse-engineering project.

## High-level idea

Each iteration:

1. Generates a pseudo-random bit `k` with xorshift32.
2. Clears or standardizes recent predictor history using a chain of conditional branches.
3. Executes a training conditional branch whose direction depends on `k`.
4. Optionally executes a controlled sequence between the training branch and test branch.
5. Executes a test conditional branch and measures whether extra mispredictions appear.

The manual sweep changes the relative alignment/distance between the relevant branch targets. If the test branch begins to cause significantly more `rc5` events at a certain relative distance, that suggests the predictor state being tested depends on those address/distance bits.

## Files

| File | Purpose |
|---|---|
| `tb.S` | Main hand-written AArch64 assembly benchmark. Contains the random-bit loop, PHR clear loop, training branch, optional jump gap, and test branch. |
| `tb_1.S` | Alternate/control assembly variant used for the comparison case. |
| `clear_phr.S` | Small helper benchmark for exercising the clear-history branch pattern by itself. |
| `linker.ld` | Places `.text.init`, `.text.main`, and `.text.uncond_jumps` at fixed virtual addresses. |
| `script.txt` | Manual build, symbol-check, and `perf stat` commands. |
| `phr_target_revisit_copy.py` | Historical hard-coded plotting script for the recorded data points. |
| `plot_miss_predictions.py` | Historical helper that writes the plotting script to the original local repo path. Prefer the standalone plotter included below for reuse. |
| `miss_predictions_comparison.png` | Plot comparing `with_test_branch` and `without_test_branch`. |
| `miss_predictions_difference.png` | Plot of `with_test_branch - without_test_branch`. |
| `perf.data`, `perf.data.old` | Saved `perf record` outputs from prior runs. |
| `tb`, `tb_1` | Built binaries from prior runs. Generated artifacts, not source. |

## Requirements

This benchmark is intended for the same environment as the rest of the M1 CBP reverse-engineering suite:

- Apple M1 / Firestorm core.
- Linux environment with Apple PMU event support.
- `gcc` capable of assembling/linking AArch64 assembly.
- `perf` with access to `apple_firestorm_pmu/rc5/`.
- `taskset` for CPU pinning.
- Python 3 with `matplotlib` for plotting.

The existing commands pin the benchmark to core 4:

```bash
taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ ./tb
```

## Build and run

From this directory:

```bash
gcc -nostdlib -nostartfiles -ffreestanding -fno-pie -no-pie \
    -Wl,-Tlinker.ld -Wl,--build-id=none \
    -o tb tb.S
```

Check important symbol placement:

```bash
nm -n tb | grep -E '(_start|L_target_clear|L_jump_clear|Train_Branch|Label_Test1|Label_Test2|lbl_tr|lbl_ts1|lbl_ts2)'
```

Run the PMU measurement:

```bash
taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ ./tb
```

The historical command script contains the same build, `nm`, and `perf stat` flow.

## Manual sweep procedure

This folder was not primarily an automated sweep. The data was collected by manually editing the assembly and recording `rc5` for each setting.

Typical workflow:

1. Choose the relative distance/alignment bit to test, for example 11 through 19.
2. Edit the relevant `.p2align` and/or spacing in `tb.S` or the control variant.
3. Build with the command above.
4. Use `nm -n tb` to verify that the branch labels moved as expected.
5. Run `perf stat` on core 4.
6. Record the `rc5` value.
7. Repeat for both the `with_test_branch` and `without_test_branch` cases.
8. Plot the comparison and difference.

## Recorded data

The historical plot used these manually collected points:

| Relative distance bits | With test branch | Without test branch | Difference |
|---:|---:|---:|---:|
| 11 | 150234 | 150213 | 21 |
| 12 | 150187 | 150109 | 78 |
| 13 | 150392 | 150250 | 142 |
| 14 | 150420 | 150335 | 85 |
| 15 | 150548 | 150251 | 297 |
| 16 | 150725 | 150131 | 594 |
| 17 | 151278 | 150315 | 963 |
| 18 | 159838 | 150403 | 9435 |
| 19 | 182457 | 150638 | 31819 |

The control stays near the baseline of roughly 150k `rc5` events. The `with_test_branch` case begins to diverge visibly at distance bit 18 and becomes much larger at bit 19.

## Plotting

Using the cleaned plotting helper included with this README:

```bash
python3 plot_phr_target_revisit_conditional.py \
    phr_target_revisit_conditional_points.csv \
    --outdir plots
```

This writes:

- `plots/miss_predictions_comparison.png`
- `plots/miss_predictions_difference.png`
- `plots/phr_target_revisit_conditional_with_difference.csv`

The historical hard-coded script can also be run directly:

```bash
python3 phr_target_revisit_copy.py
```

## Interpretation

The result is consistent with the test/probe branch only producing a meaningful extra collision or revisit effect when the relative branch/target distance reaches the larger tested spacing values.

A cautious interpretation:

- Bits 11-17: little to no extra effect beyond baseline noise.
- Bit 18: measurable increase in extra mispredictions.
- Bit 19: strong increase in extra mispredictions.

This suggests the predictor structure being tested may involve address or target-history bits in this region. However, this experiment alone should not be treated as a complete proof of the exact index function. It should be read together with the PC-bit aliasing, PHRT position, and associativity sweeps.

## Notes and caveats

- The benchmark uses fixed virtual placement via `linker.ld`; changing the linker script can invalidate comparisons.
- The data was collected manually, so the exact assembly variant for each point should be preserved if you need strict reproducibility.
- `tb` and `tb_1` are generated binaries and should not be treated as source.
- `perf.data` files are useful for checking where samples landed, but the main plotted metric is `perf stat` `rc5`.
- Re-run several times if making a formal claim from the exact threshold, because PMU counts can vary slightly between runs.
