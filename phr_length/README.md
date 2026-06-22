# phr_length

PHR length sweep using a randomized target-history injection followed by a configurable number of dummy unconditional branches and one conditional probe.

This experiment estimates how many branch-history entries remain visible to the predictor by varying the number of dummy branches between an injected random bit and the later probe branch.

## Files

| File | Purpose |
|---|---|
| `phr_tb.c` | C wrapper for `phr_test(tries, dummy_count)`. |
| `phr_test_a64.S` | AArch64 benchmark loop. Generates random `k`, jumps to `L0`/`L1`, runs dummy branches, then probes on `k`. |
| `gen_phr_dummy.py` | Generates the dummy jump table and dummy branch entries. |
| `sweep_phr.py` | Automates `perf stat` across a range of dummy counts and plots `rc5 / iters`. |
| `script_to_run.txt` | Original command notes. |
| `out/phr_rc5_sweep.csv` | Existing example sweep output, if present. |

## Important generated file note

`phr_test_a64.S` includes:

```asm
.include "phr_dummy.inc"
```

So the generated dummy include should be named:

```bash
python3 gen_phr_dummy.py > phr_dummy.inc
```

The original notes contain `dummy_entries.inc`; that name will not match the current assembly unless you also edit the `.include` line.

## Build

```bash
python3 gen_phr_dummy.py > phr_dummy.inc

gcc -c phr_test_a64.S
gcc -O2 -c phr_tb.c
gcc -o phr_test phr_tb.o phr_test_a64.o
```

## Single run

Firestorm example:

```bash
taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ \
    ./phr_test 20000000 97

taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ \
    ./phr_test 20000000 98
```

Icestorm example from the original notes:

```bash
taskset -c 0 perf stat -e apple_icestorm_pmu/rc5/ \
    ./phr_test 20000000 57

taskset -c 0 perf stat -e apple_icestorm_pmu/rc5/ \
    ./phr_test 20000000 58
```

Arguments:

```text
./phr_test <tries> <dummy_count>
```

## Sweep

```bash
chmod +x sweep_phr.py

./sweep_phr.py \
    --core 4 \
    --event apple_firestorm_pmu/rc5/ \
    --iters 20000000 \
    --start 0 \
    --end 98
```

Outputs:

```text
out/phr_rc5_sweep.csv
out/phr_rc5_sweep.png
```

The sweep script writes `dummy + 2` as the reported x-axis value, so the plotted branch count includes two extra fixed branches in the test structure.

## Interpretation

The benchmark structure is:

```text
k = random bit
indirect branch to L0/L1 based on k
N dummy unconditional taken branches
probe conditional branch based on k
```

If `rc5 / iter` remains low, the predictor is still able to use the injected `k` history. When `rc5 / iter` rises toward random behavior, the relevant history has likely shifted out or stopped contributing usefully. The transition point is used as an empirical estimate of PHR/history length.

## Notes

- `MAX_DUMMY` is 256 in the assembly and generator.
- Keep CPU pinning and PMU event selection consistent when comparing results.
- Treat the cutoff as empirical; exact transition points may move with alignment, code layout, core type, and measurement noise.
