# pht_reverse_scan

This folder contains a manual reverse-order scan used to test whether the Apple M1
Firestorm branch-history state is updated in an order-sensitive way.

The experiment compares two related microbenchmarks:

1. a forward baseline that calls probe branches in increasing PC/order, and
2. a reverse/alternating version that changes the probe-branch call order.

The goal is to see whether the PHT collision behavior depends only on the
artificially constructed PHR state from `func_set_phr`, or whether the immediately
previous probe branches also update the PHR in a way that affects later probes.

## Files

| File | Purpose |
| --- | --- |
| `tb_full.S` | Forward-order baseline. It calls `branch1` through `branch8` in order. |
| `tb_full_reverse.S` | Reverse-scan version. It alternates between forward and reverse call order every loop iteration. |
| `linker.ld` | Places `.phr` and each branch section at controlled virtual addresses. |
| `pht_tb` | Built binary for the forward baseline. |
| `pht_tb_reverse` | Built binary for the reverse-order version. |
| `script.txt` | Original manual build and `perf` command notes. |
| `perf.data`, `perf.data.old` | Saved `perf record` outputs from previous runs. |

## What this test measures

Each probe branch calls `func_set_phr` before executing its own conditional
probe branch.

`func_set_phr` injects a random bit `k` into the branch-history path using two
conditional branches whose targets are 4 bytes apart, then runs through a long
chain of unconditional branches. The probe branches then use the same `k` value
for their branch condition.

The interesting question is:

```text
After one probe branch executes, does its outcome / PC update the PHR in a way
that immediately affects the next probe branch?
```

The forward baseline always probes in this order:

```text
branch1 -> branch2 -> branch3 -> ... -> branch8
```

The reverse version alternates each outer-loop iteration:

```text
forward iteration: branch1 -> branch2 -> branch3 -> ...
reverse iteration: ... -> branch3 -> branch2 -> branch1
```

If the PHR state used by each probe is fully controlled by `func_set_phr`, then
changing the probe call order should not significantly change the collision
behavior.

If the PHR update is immediate and order-sensitive, then reversing the order can
change which probe branch sees which history state. That can change the observed
`rc5` misprediction count and the `perf record` attribution.

## Current reverse-scan configuration

In the uploaded `tb_full_reverse.S`, the active reverse-scan case is a 3-probe
test:

```text
forward path: branch1 -> branch2 -> branch3
reverse path: branch3 -> branch2 -> branch1
```

`branch4` through `branch8` are present but commented out in both the forward and
reverse paths.

To test a different number of probe branches, edit `tb_full_reverse.S` manually.
Keep the active branch set symmetric:

```text
N = 2:
  forward: branch1 -> branch2
  reverse: branch2 -> branch1

N = 4:
  forward: branch1 -> branch2 -> branch3 -> branch4
  reverse: branch4 -> branch3 -> branch2 -> branch1

N = 8:
  forward: branch1 -> ... -> branch8
  reverse: branch8 -> ... -> branch1
```

Rebuild after every edit.

## Build

Forward baseline:

```bash
gcc -nostdlib -nostartfiles -ffreestanding -fno-pie -no-pie \
    -Wl,-Tlinker.ld -Wl,--build-id=none \
    -o pht_tb tb_full.S
```

Reverse-order version:

```bash
gcc -nostdlib -nostartfiles -ffreestanding -fno-pie -no-pie \
    -Wl,-Tlinker.ld -Wl,--build-id=none \
    -o pht_tb_reverse tb_full_reverse.S
```

## Check symbol placement

For the forward baseline:

```bash
nm -n pht_tb | grep -E '(_start|func_set_phr|branch1|branch2|branch3|branch4|branch5|branch6|branch7|branch8)'
```

For the reverse-order version:

```bash
nm -n pht_tb_reverse | grep -E '(_start|func_set_phr|branch1|branch2|branch3|branch4|branch5|branch6|branch7|branch8)'
```

The linker script places the branch sections far apart while keeping the probe
instruction offsets controlled by the branch macro. In the assembly, the probe
branches are generated with increasing `pad_nops`, so their probe PCs differ by
4 bytes from one branch instance to the next.

## Run with perf stat

Forward baseline:

```bash
taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ ./pht_tb
```

Reverse-order version:

```bash
taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ ./pht_tb_reverse
```

`rc5` is used here as the Firestorm branch-misprediction event. The benchmark is
usually pinned to CPU core 4 so the run stays on the same Firestorm core.

## Run with perf record

Forward baseline:

```bash
taskset -c 4 perf record -c 10 -e apple_firestorm_pmu/rc5/ ./pht_tb
```

Reverse-order version:

```bash
taskset -c 4 perf record -c 10 -e apple_firestorm_pmu/rc5/ ./pht_tb_reverse
```

Then inspect the attribution:

```bash
perf report
```

or:

```bash
perf annotate
```

This can help identify whether mispredictions concentrate on the same probe
branch before and after reversing the call order.

## Suggested manual workflow

1. Build and run the forward baseline.
2. Build and run `tb_full_reverse.S` with the same active probe count.
3. Record `rc5` for both.
4. Use `perf record` if the aggregate count changes.
5. Change the active branch count manually.
6. Repeat.

A simple manual notes table is useful:

| Active probes | Forward `rc5` | Reverse `rc5` | Main sampled branch | Interpretation |
| --- | ---: | ---: | --- | --- |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |
| 8 | | | | |

## Interpreting results

| Observation | Possible interpretation |
| --- | --- |
| Forward and reverse have similar high `rc5` | The constructed PHR state from `func_set_phr` likely dominates; reversing probe order does not break the collision. |
| Reverse order significantly changes `rc5` | The PHR update is likely order-sensitive; previous probe branches may be entering the history seen by later probes. |
| Mispredictions move from one branch to another in `perf record` | The update policy may be changing which probe branch occupies the conflicting predictor entry. |
| More active probes are needed before the effect appears | The effect may depend on associativity pressure or on how many recent probe updates are retained. |

This experiment is mainly qualitative. It is useful for deciding whether the PHR
update policy is immediate/order-sensitive, but it should be interpreted together
with the PHR-position scan and PHT-associativity sweep.

## Notes and limitations

- This folder is mostly manual; there is no automated sweep script here.
- `perf.data` is overwritten by `perf record`, so rename it if you want to keep
  multiple runs.
- Keep the same active branch set when comparing forward and reverse order.
- Re-run each case several times if the counts are close.
- Do not compare runs across different CPU cores.
- The binary is Linux/AArch64-specific and relies on the Apple Firestorm PMU
  event name being available through `perf`.
