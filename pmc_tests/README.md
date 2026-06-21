# PMC Branch Tests

`pmc_branch_suite.c` is a small microbenchmark suite for checking Apple M1/Firestorm branch-related performance-monitoring counters. It provides controlled conditional-branch and indirect-branch workloads that can be measured with Linux `perf`.

## Included tests

| Mode | Description |
|---|---|
| `predictable` | Conditional branch that is taken on every iteration except the last. |
| `random` | Approximately 50/50 taken/not-taken conditional branch driven by a deterministic xorshift PRNG. |
| `biased` | Biased conditional branch that is taken 7 out of 8 times (87.5%). |
| `indirect_const` | Indirect function call whose target is always `target_A`. |
| `indirect_random` | Indirect function call that randomly selects between `target_A` and `target_B`. |

The program performs a short warm-up before executing the selected test. A volatile global variable, `sink`, is used to keep the test work observable.

## Build

Compile with optimizations disabled so the compiler is less likely to remove or transform the intended branches:

```bash
gcc -O0 -o pmc_branch_suite pmc_branch_suite.c
```

The exact machine code should be inspected with `objdump` when using these tests for precise microarchitectural measurements, because compiler version and optimization flags can change the generated branches.

## Run

```bash
./pmc_branch_suite MODE ITERATIONS
```

For example:

```bash
./pmc_branch_suite predictable 1000000
./pmc_branch_suite random 1000000
./pmc_branch_suite biased 1000000
./pmc_branch_suite indirect_const 1000000
./pmc_branch_suite indirect_random 1000000
```

## Measure with `perf`

The source identifies the following Firestorm raw PMU events:

| Event | Meaning |
|---|---|
| `r8d` | All conditional branches |
| `rc5` | Conditional branch mispredictions |
| `rc6` | Indirect branch mispredictions |
| `rcb` | All branch mispredictions |

Example:

```bash
perf stat \
  -e apple_firestorm_pmu/r8d/ \
  -e apple_firestorm_pmu/rc5/ \
  -e apple_firestorm_pmu/rc6/ \
  -e apple_firestorm_pmu/rcb/ \
  ./pmc_branch_suite random 1000000
```

Pinning the process to a Firestorm performance core is recommended for repeatable measurements. Replace `<CPU>` with the appropriate logical CPU on the test system:

```bash
taskset -c <CPU> perf stat \
  -e apple_firestorm_pmu/r8d/ \
  -e apple_firestorm_pmu/rc5/ \
  -e apple_firestorm_pmu/rc6/ \
  -e apple_firestorm_pmu/rcb/ \
  ./pmc_branch_suite random 1000000
```

## Current source issue

The final `printf` call is missing the `iters` argument. Change:

```c
printf("Done: mode=%s, iters=%ld, sink=%d\n", mode, sink);
```

to:

```c
printf("Done: mode=%s, iters=%ld, sink=%d\n", mode, iters, sink);
```
