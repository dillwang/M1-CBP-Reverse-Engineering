# phr_T1NT_RE

Manual AArch64 test for checking whether a long run of not-taken conditional branches affects the predictor history used by a later correlated probe branch.

The name refers to a taken/not-taken style PHR experiment. The benchmark creates a random train/probe pair around a fixed dummy chain. The dummy chain can be configured to behave as all-taken or all-not-taken by changing the value in `x20`.

## Files

| File | Purpose |
|---|---|
| `tb.S` | Complete standalone benchmark with `main`, train/probe branches, and a 98-entry dummy chain. |
| `script.txt` | Original build and `perf stat` commands. |

## Benchmark structure

Per iteration:

```text
k = xorshift32() & 1

Train:
    cbnz k, L_train

Dummy chain:
    controlled by x20
    x20 = 0  -> all dummy branches are taken
    x20 = 1  -> all dummy branches are not taken

Probe:
    cbnz k, L_probe
```

The current source does:

```asm
// warmup
mov x20, #0
bl  dummy_chain

// measurement
mov x20, #1
```

So the measured loop uses the **all-not-taken** dummy-chain mode.

## Build

```bash
g++ -O2 -fno-pie -no-pie tb.S -o tb
```

## Run

```bash
taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ ./tb
```

## How to modify the experiment

In `tb.S`, change the measurement setting:

```asm
mov x20, #1
```

to:

```asm
mov x20, #0
```

to compare all-not-taken dummy history against all-taken dummy history.

## Interpretation

- Lower `rc5` suggests that the probe branch is still being predicted using useful history from the train branch.
- Higher `rc5` suggests that the intervening dummy branches changed or displaced the relevant history.
- Comparing `x20 = 0` and `x20 = 1` helps test whether not-taken conditional branches are inserted into the same history structure used by the probe.

## Notes

- The loop count is hardcoded to 1,000,000 iterations.
- The dummy chain currently contains labels `L1` through `L98`.
- This benchmark is manual: edit `tb.S`, rebuild, and rerun.
