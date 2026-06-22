# ghr_tests

Small AArch64 microbenchmarks for checking whether earlier branch outcomes remain visible to later prediction decisions after a configurable number of intervening branches.

The folder contains three related test styles:

- `ghr_tb.c` + `ghr_a64.S`: a GHR-style two-branch test. Each inner iteration reads one pseudo-random bit, executes a first conditional branch using that bit, executes a configurable number of dummy branches, and then executes a second conditional branch using the same bit.
- `pair_tb.c` + `pair_a64.S` + generated `dummy_chain_a64.S`: a train/test pair experiment. The first branch trains on random `k`, a dummy branch chain executes, and the second branch probes whether the earlier branch is still useful.
- `ghr100_test.c` + `ghr100_patterns.S`: a fixed 100-history experiment comparing pattern `A` and pattern `B`, where the first 99 history branches are identical and history branch #100 is flipped.

## Files

| File | Purpose |
|---|---|
| `ghr_tb.c` | C wrapper for `ghr_test(outer_iters, inner_iters, dummy_count)`. |
| `ghr_a64.S` | Main GHR-style two-branch loop with pseudo-random input bits and configurable dummy branches. |
| `pair_tb.c` | C wrapper for `pair_test(num_tries, dummy_count)`. |
| `pair_a64.S` | Train/test branch-pair experiment using a generated dummy chain. |
| `gen_dummy_chain.py` | Generates `dummy_chain_a64.S` with up to 256 unique dummy-branch entries. |
| `dummy_chain_a64.S` | Generated or checked-in dummy chain used by the pair test. |
| `ghr100_test.c` | C wrapper for pattern `A` / `B` 100-history tests. |
| `ghr100_patterns.S` | Implements pattern `A` and pattern `B`; they differ only at history bit #100. |
| `gen_dummy_entries.py`, `dummy_entries.inc`, `pair_a64_inline.S`, `pair_a64 copy.S` | Older or alternate variants kept for reference. |

## Requirements

- Apple Silicon Linux environment with access to Apple PMU events.
- AArch64 GCC toolchain.
- `perf`.
- `taskset`.
- Usually run on a pinned Firestorm performance core, for example core `4`.

## Build

### GHR-style two-branch test

```bash
gcc -O2 ghr_tb.c ghr_a64.S -o ghr_test
```

### Pair train/test test

Generate the dummy chain if needed:

```bash
python3 gen_dummy_chain.py > dummy_chain_a64.S
```

Build:

```bash
gcc -O2 pair_tb.c pair_a64.S dummy_chain_a64.S -o pair_test
```

### 100-history A/B test

```bash
gcc -O2 ghr100_test.c ghr100_patterns.S -o ghr100_test
```

## Run

### GHR-style two-branch test

```bash
taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ \
    ./ghr_test 10 30000 100
```

Arguments:

```text
./ghr_test <outer_iters> <inner_iters> <dummy_count>
```

### Pair train/test test

```bash
taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ \
    ./pair_test 200000000 80
```

Arguments:

```text
./pair_test <num_tries> <dummy_count>
```

### 100-history A/B test

```bash
taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ \
    ./ghr100_test A 20000000

taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ \
    ./ghr100_test B 20000000
```

Arguments:

```text
./ghr100_test A|B <iterations>
```

## Interpretation

These tests are mainly for coarse PHR/GHR sensitivity checks.

- If the second/probe branch remains predictable when many dummy branches are inserted, then the relevant earlier branch information is likely still present in the predictor history used by that branch.
- If the probe becomes close to random as `dummy_count` increases, the earlier branch information was likely shifted out or no longer indexed in the same useful way.
- In the `ghr100` test, pattern `A` and `B` differ only at history branch #100, so any stable counter difference suggests that the predictor can still observe that remote history bit.

## Notes

- `apple_firestorm_pmu/rc5/` is used throughout this repository as the conditional branch misprediction counter on Firestorm.
- Keep the CPU core fixed while comparing runs.
- These are microbenchmarks, not formal proofs. Treat threshold changes as evidence for a predictor-history effect, not as an exact architectural disclosure.
