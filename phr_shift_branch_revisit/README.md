# phr_shift_branch_revisit

Minimal revisit version of the PHR branch-shift experiment.

This folder contains a single standalone AArch64 assembly benchmark. It injects one of two branch paths based on a random bit, inserts a fixed unconditional dummy chain, and then probes with a conditional branch using the same flags.

## Files

| File | Purpose |
|---|---|
| `tb.S` | Standalone `_start` benchmark. No C wrapper is needed. |

## Benchmark structure

The loop runs 100,000 iterations:

```text
k = xorshift32() & 1
cmp k, 1

branch_a:
    b.eq L0

padding / optional alignment

branch_b:
    b.ne L0

L0:
    30 dummy unconditional jumps

after_dummies:
    b.ne probe_tgt
```

The probe branch uses the same condition flags from `cmp w11, #1`. The intervening dummy branches are unconditional, so they should not modify NZCV flags.

## Build

```bash
gcc -nostdlib -nostartfiles -ffreestanding \
    -Wl,--build-id=none \
    -o tb tb.S
```

## Run

```bash
taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ ./tb
```

You can also use other Firestorm PMU events by replacing `rc5`.

## Manual knobs

In `tb.S`:

```asm
.rept 256
nop
.endr

#.p2align 10, 0xD503201F
```

The `.rept 256` block currently controls the distance between `branch_a` and `branch_b`. The `.p2align` line is commented out. Uncomment or change it to test specific alignment boundaries.

The dummy chain is hardcoded to 30 unconditional jumps.

## Interpretation

This is a compact sanity-check version of `phr_shift_branch`.

- If the probe misprediction count changes when the spacing/alignment between `branch_a` and `branch_b` changes, the predictor history state may be sensitive to the PC bits being moved.
- Because this file is small and standalone, it is useful for quickly testing a hypothesis before using the larger parameterized sweep.

## Notes

- The loop count is hardcoded to 100,000.
- There is no output other than the `perf stat` result.
- This experiment is manual: edit spacing/alignment, rebuild, and rerun.
