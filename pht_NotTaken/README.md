# pht_NotTaken

## Purpose

This folder contains a manual Apple M1 Firestorm PHT/PHR microbenchmark for testing whether **not-taken conditional branches update the path history register (PHR)**.

The experiment starts from a known PHT collision setup:

- `branch1` and `branch2` both call the same `func_set_phr` routine.
- `func_set_phr` injects a random taken/not-taken history bit from `k = xorshift32(seed) & 1`, then runs a long chain of unconditional branches.
- `branch1_probe` and `branch2_probe` use opposite branch directions from the same random bit.
- If both probe branches reach the predictor with the same PHR/index context, they collide and fight in the PHT, causing high `rc5` conditional branch mispredictions.
- If extra not-taken branches before `branch1_probe` change the PHR, then `branch1_probe` should no longer collide with `branch2_probe`, and `rc5` should drop.

In short:

```text
collision still high  => added not-taken branch did NOT change the relevant PHR state
collision disappears  => added not-taken branch DID change the relevant PHR state
```

This was not an automated sweep. The intended workflow is to manually comment/uncomment not-taken branches in `tb_full.S`, rebuild, and compare the `rc5` count.

## Files

| File | Purpose |
|---|---|
| `tb_full.S` | Main AArch64 assembly test. Contains the loop, `branch1`, `branch2`, optional not-taken branches, and `func_set_phr`. |
| `linker.ld` | Places sections at controlled virtual addresses so the branch functions and PHR-setting code stay separated and stable. |
| `script.txt` | Command notes for building, checking symbols, collecting `perf stat`, and recording sampled PMU events. |
| `pht_tb` | Previously built test binary. Rebuild this after editing `tb_full.S`. |
| `perf.data`, `perf.data.old` | Previous `perf record` outputs. These are generated analysis artifacts, not source inputs. |

## Current test shape

The loop in `_start` runs for `1,000,000` iterations. Each iteration:

1. Updates a xorshift32 random state.
2. Computes `k = random & 1` in `w0`.
3. Calls `branch1`.
4. Calls `branch2`.

`branch1` and `branch2` both call `func_set_phr`, then execute their probe branch. The probe branches intentionally use opposite conditions:

```asm
branch1_probe:
    cmp     w0, #0
    b.ne    branch1_taken
```

```asm
branch2_probe:
    cmp     w0, #0
    b.eq    branch2_taken
```

The optional not-taken branch block is located in `branch1`, after `func_set_phr` and before `branch1_probe`:

```asm
branch1_nt:
    // Not taken branch
    cbz w1, first_iteration_1
    # cbz w1, nt_fall_1
nt_fall_1:
#    cbz w2, first_iteration_2
# nt_fall_2:
#    cbz w3, first_iteration_3
    nop
    nop
```

The currently active `cbz w1, first_iteration_1` is taken only on the first iteration. It sets `w1 = 1`, then all later executions of that branch are not taken:

```asm
first_iteration_1:
    // set w1 to 1 so the later ones are all not taken branches
    mov     w1, #1
    b       nt_fall_1
```

## Build

From this folder:

```bash
gcc -nostdlib -nostartfiles -ffreestanding -fno-pie -no-pie \
  -Wl,-Tlinker.ld -Wl,--build-id=none \
  -o pht_tb tb_full.S
```

## Check symbol placement

After building, check the important symbol addresses:

```bash
nm -n pht_tb | grep -E '(_start|func_set_phr|branch1|branch2)'
```

The linker script places the relevant sections at controlled addresses:

- `_start` / startup code near `0x00400000`
- `branch1` near `0x10000000`
- `func_set_phr` near `0x10100000`
- `branch2` near `0x20000000`

Do not rely only on the intended linker layout; use `nm` to confirm the actual binary.

## Run

Measure conditional branch mispredictions with Firestorm PMU event `rc5`:

```bash
taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ ./pht_tb
```

A sampled run can also be collected with:

```bash
taskset -c 4 perf record -c 10 -e apple_firestorm_pmu/rc5/ ./pht_tb
```

Then inspect with:

```bash
perf report
```

## Manual experiment procedure

### 1. Baseline collision

First measure the collision case with no extra not-taken branches before `branch1_probe`, or with the known reference version. Record the `rc5` count.

Suggested log format:

```text
case,active_extra_not_taken_branches,rc5,notes
baseline,0,,
one_nt,1,,
two_nt,2,,
three_nt,3,,
```

### 2. Enable one not-taken branch

Use the active `w1` branch. The current file already contains this case:

```asm
mov     w1, #0
...
cbz w1, first_iteration_1
...
first_iteration_1:
    mov     w1, #1
    b       nt_fall_1
```

This branch is taken once for setup, then not taken for the remaining iterations.

Rebuild and rerun `perf stat`.

### 3. Enable more not-taken branches

To test multiple not-taken branches, uncomment the `w2` / `w3` setup and the corresponding `cbz` / `first_iteration` blocks.

For two not-taken branches, enable:

```asm
mov     w1, #0
mov     w2, #0
```

and:

```asm
cbz w1, first_iteration_1
nt_fall_1:
cbz w2, first_iteration_2
nt_fall_2:
```

plus:

```asm
first_iteration_1:
    mov     w1, #1
    b       nt_fall_1

first_iteration_2:
    mov     w2, #1
    b       nt_fall_2
```

For three not-taken branches, do the same for `w3`.

After every edit:

```bash
gcc -nostdlib -nostartfiles -ffreestanding -fno-pie -no-pie \
  -Wl,-Tlinker.ld -Wl,--build-id=none \
  -o pht_tb tb_full.S

taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ ./pht_tb
```

## Interpretation

The important comparison is the `rc5` count relative to the original collision baseline.

| Observation | Interpretation |
|---|---|
| `rc5` remains high after adding not-taken branches | The added not-taken branches likely do not perturb the PHR bits/index bits used by this collision. The two probe branches still collide. |
| `rc5` drops significantly after adding not-taken branches | The added not-taken branches likely change the relevant PHR state, separating the two probe branches in the PHT. |
| `rc5` changes only slightly | Treat as inconclusive. Repeat the measurement, check symbol placement, and compare against noise/baseline runs. |

Avoid claiming that all not-taken branches globally do or do not update Firestorm history from this experiment alone. This test only checks whether these inserted not-taken branches affect the specific PHT collision being measured.

## Notes and caveats

- This is a manual-edit experiment. There is no sweep script in this folder.
- Rebuild `pht_tb` after every edit to `tb_full.S`.
- Keep the same CPU core across runs. The command notes use `taskset -c 4`.
- Keep the same PMU event across runs. The intended event is `apple_firestorm_pmu/rc5/`.
- The first execution of each inserted `cbz` setup branch is taken so the register can be initialized to make later executions not taken. With `1,000,000` iterations, this one-time setup effect should be negligible, but it is still worth mentioning in final analysis.
- `perf.data` files are generated outputs from `perf record`; they are not needed for normal `perf stat` comparison.
- If the goal is publication-quality evidence, repeat each case several times and report mean/stdev rather than relying on a single `perf stat` run.
