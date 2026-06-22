# phr_length_NT

Variant of the PHR length sweep where the dummy history is built from not-taken conditional branches rather than unconditional taken branches.

This is useful for testing whether not-taken conditional branches occupy or affect the same history structure used by later prediction.

## Files

| File | Purpose |
|---|---|
| `phr_tb.c` | C wrapper for `phr_test(tries, dummy_count)`. |
| `phr_test_a64.S` | AArch64 benchmark loop. Generates random `k`, jumps to `L0`/`L1`, runs generated dummy entries, then probes on `k`. |
| `gen_phr_dummy_nt.py` | Generates dummy entries made of `cmp xzr, xzr` followed by `b.ne`, which is always not taken. |
| `sweep_phr.py` | Optional sweep script for collecting and plotting `rc5 / iters`. |
| `script_to_run.txt` | Original build and run commands. |
| `out/phr_rc5_sweep.csv` | Existing example sweep output, if present. |

## Benchmark structure

Per iteration:

```text
k = random bit
indirect branch to L0/L1 based on k
N dummy conditional branches that are always not taken
probe conditional branch based on k
```

The dummy generator emits this pattern for each dummy branch:

```asm
cmp xzr, xzr
b.ne next_label
```

Since `xzr == xzr`, the `b.ne` branch is not taken.

## Build

```bash
python3 gen_phr_dummy_nt.py > phr_dummy.inc

gcc -c phr_test_a64.S
gcc -O2 -c phr_tb.c
gcc -o phr_test_nt phr_tb.o phr_test_a64.o
```

## Single run

```bash
taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ \
    ./phr_test_nt 20000000 250
```

Arguments:

```text
./phr_test_nt <tries> <dummy_count>
```

## Sweep

```bash
chmod +x sweep_phr.py

./sweep_phr.py \
    --core 4 \
    --event apple_firestorm_pmu/rc5/ \
    --exe ./phr_test_nt \
    --iters 20000000 \
    --start 0 \
    --end 98
```

Outputs:

```text
out/phr_rc5_sweep.csv
out/phr_rc5_sweep.png
```

## Interpretation

Compare this folder against `phr_length`.

- If the not-taken dummy sweep behaves similarly to the unconditional/taken dummy sweep, it suggests not-taken conditionals also affect the relevant predictor history.
- If the sweep does not shift the transition point much, it suggests not-taken conditionals may be ignored, compressed, or represented differently in the effective history used by the probe.

## Notes

- `MAX_DUMMY` is 256.
- The probe branch is still conditional on the injected random bit `k`.
- Keep the same core, event, iteration count, and alignment when comparing against `phr_length`.
