# PHR rc5 Position Scan

This folder contains a Firestorm/M1 branch-predictor microbenchmark that scans where a test branch-history injection lands in the path/history register behavior observed by `apple_firestorm_pmu/rc5/`.

The main workflow is:

1. Build `tb_full.S` into the freestanding AArch64 binary `pht_tb`.
2. Patch the test PHR injection position from 0 through 97.
3. Run each generated binary pinned to one Firestorm core.
4. Collect the `rc5` PMU count into `phr_rc5_scan.csv`.
5. Plot `rc5 / iteration` versus tested PHR position.

## Files

| File | Purpose |
|---|---|
| `tb_full.S` | Main AArch64 benchmark. It generates a random bit, calls eight probe branch functions, and uses two PHR-setting functions: a fixed reference setter and a shifted test setter. |
| `scan_phr_positions.py` | Automated sweep script. It patches the test injection position, rebuilds `pht_tb`, runs `perf stat`, and writes `phr_rc5_scan.csv`. |
| `phr_rc5_scan.csv` | Scan output with columns `test_pos`, `rc5`, and raw `perf stat` output. |
| `pht_tb` | Generated benchmark binary. This can be rebuilt from `tb_full.S`. |
| `linker.ld` | Linker script used when rebuilding the freestanding benchmark. Verify that it matches the section layout expected by `tb_full.S`. |
| `perf.data`, `perf.data.old` | Optional `perf record` outputs. These are generated profiling artifacts, not required for the normal scan. |
| `plot_phr_rc5_scan.py` | Plotting helper for `phr_rc5_scan.csv`. |

## What the benchmark does

`tb_full.S` runs 1,000,000 iterations. Each iteration generates one pseudo-random bit `k`, stores it in `w17`, and calls `branch1` through `branch8`.

The branches are split into two groups:

- `branch1` to `branch4`: reference group using `func_set_phr_ref`.
- `branch5` to `branch8`: shifted-test group using `func_set_phr_test`.

Each branch function first calls a PHR-setting function, then executes a conditional probe branch based on the same random bit. The PHR setter is built from fixed-size slots. Most slots are dummy unconditional-control-flow slots, while exactly one slot is an injected conditional branch pair. The scan moves the injected test slot and observes how the PMU count changes.

The active scan range is position `0..97`. The assembly comments mention a 100-slot design, but slots 98 and 99 are currently commented out in `tb_full.S`, so the provided scan script only sweeps through 97.

## Requirements

This experiment is Apple M1/Firestorm-specific.

Required tools:

- Linux on Apple Silicon / Asahi-style environment
- `gcc` capable of assembling AArch64 source
- `perf`
- `taskset`
- Python 3
- Python packages for plotting: `matplotlib`

The default PMU event used by the automated script is:

```bash
apple_firestorm_pmu/rc5/u
```

The default pinned core is core `4`, which is assumed to be a Firestorm performance core on the tested machine.

## Manual build and single run

From this folder:

```bash
gcc -nostdlib -nostartfiles -ffreestanding -fno-pie -no-pie \
    -Wl,-Tlinker.ld -Wl,--build-id=none \
    -o pht_tb tb_full.S
```

Check important symbol placement:

```bash
nm -n pht_tb | grep -E '(_start|func_set_phr|branch[1-8])'
```

Run one PMU measurement:

```bash
taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/u ./pht_tb
```

Optional profiling run:

```bash
taskset -c 4 perf record -c 10 -e apple_firestorm_pmu/rc5/u ./pht_tb
```

## Automated scan

Run:

```bash
python3 scan_phr_positions.py
```

The script does the following:

1. Reads `tb_full.S`.
2. Patches either `.set TEST_POS, <n>` or the `BUILD_SET_PHR_FUNC func_set_phr_test, <n>` macro argument.
3. Rebuilds `pht_tb`.
4. Runs:

```bash
taskset -c 4 perf stat -x , -r 1 -e apple_firestorm_pmu/rc5/u ./pht_tb
```

5. Appends the measured count to `phr_rc5_scan.csv`.
6. Restores the original `tb_full.S` in a `finally` block.

The current constants in `scan_phr_positions.py` are:

```python
START_POS = 0
END_POS = 97
CPU_CORE = "4"
PERF_REPEATS = 1
EVENT = "apple_firestorm_pmu/rc5/u"
```

Note: `PERF_REPEATS` appears twice in the script. It is first set to `5`, then later overwritten to `1`. The actual repeat count is therefore `1`.

## Plotting results

After generating `phr_rc5_scan.csv`, run:

```bash
python3 plot_phr_rc5_scan.py phr_rc5_scan.csv --iters 1000000 --outdir plots
```

This writes:

```text
plots/phr_rc5_scan_normalized.csv
plots/phr_rc5_scan_top_positions.csv
plots/phr_rc5_scan_rc5_per_iter.png
plots/phr_rc5_scan_excess_per_iter.png
```

The main plot to inspect is:

```text
plots/phr_rc5_scan_rc5_per_iter.png
```

This shows the raw PMU count normalized by the 1,000,000 benchmark iterations.

The excess plot subtracts a baseline. By default, the plotting script estimates the baseline as the median of the lowest 10% of `rc5` values. To force a specific baseline:

```bash
python3 plot_phr_rc5_scan.py phr_rc5_scan.csv \
    --iters 1000000 \
    --baseline-rc5 1000000 \
    --outdir plots
```

## Interpreting the CSV

`phr_rc5_scan.csv` has the format:

| Column | Meaning |
|---|---|
| `test_pos` | Injected test PHR slot position. |
| `rc5` | Raw `apple_firestorm_pmu/rc5/u` count from `perf stat`. |
| `raw` | Full raw comma-separated `perf stat -x ,` line. |

A higher `rc5 / iteration` value indicates that this test position caused more counted branch-prediction events under this benchmark setup. Treat peaks as evidence of aliasing/sensitivity at those positions, not as a complete standalone proof of predictor structure.

## Reproducibility notes

- Keep the benchmark pinned to the same Firestorm core when comparing runs.
- Recheck symbol placement after changing `linker.ld`, section names, or the assembly macros.
- The generated binary layout matters. If branch or PHR-setting functions move, results may change.
- Avoid mixing CSVs collected with different loop counts, PMU events, cores, or linker layouts.
- `perf.data` files are not needed for the CSV scan; regenerate them only when doing detailed profile inspection.
