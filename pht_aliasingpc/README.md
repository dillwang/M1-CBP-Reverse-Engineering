# PHT PC-Index Bit Collision Test

This folder contains a manual microbenchmark for probing which branch PC address bits appear to participate in the Apple M1 / Firestorm conditional-branch predictor PHT index function.

The experiment tries to force two conditional branches to map to the same PHT entry under the same constructed PHR state. The two probe branches are given opposite behavior on the same random bit `k`, so if they collide, they train contradictory directions and produce a high `rc5` branch-misprediction count. By changing the relative alignment and address bits of the two branch PCs, the test can be used to infer which PC bits matter for the PHT index or tag path.

## Main idea

The benchmark repeatedly runs:

```text
for many iterations:
    k = xorshift_random_bit()
    call branch1
    call branch2
```

Each branch does roughly:

```text
branch1:
    call func_set_phr(k)
    branch1_probe: branch on k in one direction

branch2:
    call func_set_phr(k)
    branch2_probe: branch on k in the opposite direction
```

`func_set_phr` constructs a mostly fixed path history, with one injected target-history bit derived from `k`. The current version does this by selecting between `.L0_inject` and `.L1_inject`, which are placed 4 bytes apart, then falling into a long chain of unconditional branches before returning.

If `branch1_probe` and `branch2_probe` use the same PHT entry under the same effective history, they interfere with each other. This should show up as a large `apple_firestorm_pmu/rc5/` count. If changing one PC address bit makes the interference disappear, that PC bit is a candidate input to the predictor index/tag function.

## Files

| File | Purpose |
| --- | --- |
| `tb_full.S` | Main hand-written AArch64 testbench with `_start`, `branch1`, `branch2`, and `func_set_phr`. |
| `tb_part.S` | Alternate / partial version of the same idea, useful for comparing earlier alignment variants. |
| `set_phr.s` | Standalone `func_set_phr` prototype that injects `k` into the path/target history and then walks a branch chain. |
| `linker.ld` | Main linker script. Places `.phr`, `.br1`, `.br2`, etc. at fixed virtual addresses. |
| `linker copy.ld`, `linker copy 2.ld` | Older linker-layout variants kept for reference. |
| `pseudo_code.text` | Design notes and pseudo-code for the PC-bit collision experiment. |
| `script.txt` | Manual build, symbol-check, `perf stat`, and `perf record` commands. |
| `pht_tb` | Generated binary from `tb_full.S`; should be treated as a build artifact. |
| `perf.data`, `perf.data.old` | Generated `perf record` output; should be treated as measurement artifacts. |

## Build

From this directory:

```bash
gcc -nostdlib -nostartfiles -ffreestanding -fno-pie -no-pie \
    -Wl,-Tlinker.ld -Wl,--build-id=none \
    -o pht_tb tb_full.S
```

The flags intentionally build a freestanding non-PIE binary with `_start` as the entry point. The custom linker script is important because this experiment depends on fixed code addresses.

## Check symbol placement

The original command was:

```bash
nm -n pht_tb | grep -E '(_start|func_set_phr|branch1|branch2)'
```

For this specific experiment it is also useful to inspect probe labels when they are emitted into the symbol table:

```bash
nm -n pht_tb | grep -E '(_start|func_set_phr|branch1|branch2|branch1_probe|branch2_probe)'
```

Use the printed addresses to verify that the branch probe PCs have the intended matching or differing low address bits.

## Run with perf

Measure raw conditional-branch mispredictions on Firestorm core 4:

```bash
taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ ./pht_tb
```

Collect sampled misprediction locations:

```bash
taskset -c 4 perf record -c 10 -e apple_firestorm_pmu/rc5/ ./pht_tb
```

Then inspect the profile with:

```bash
perf report
```

High samples around `branch1_probe` and/or `branch2_probe` indicate that the intended probe branches are responsible for the mispredictions, rather than some setup branch in `func_set_phr`.

## Manual PC-bit scan workflow

This folder is not an automated sweep. The intended workflow is manual:

1. Choose a candidate PC bit or alignment level `i`.
2. Edit the alignment / padding near `branch1_probe` and `branch2_probe` in `tb_full.S`.
3. Rebuild `pht_tb`.
4. Use `nm -n` to confirm the actual probe addresses.
5. Run `perf stat` on `apple_firestorm_pmu/rc5/`.
6. Optionally run `perf record` to confirm the samples come from the probe branches.
7. Compare `rc5` against the previous alignment setting.

The practical question is:

```text
Do branch1_probe and branch2_probe still collide after this PC bit changes?
```

Interpretation:

| Observation | Possible meaning |
| --- | --- |
| High `rc5` remains after changing a PC bit | The two probes may still map to the same PHT entry; the changed bit may not affect the relevant index/tag path, or the hash may cancel it. |
| `rc5` drops sharply after changing a PC bit | The changed bit likely affects the PHT index/tag path or otherwise prevents aliasing. |
| Samples move away from the probe branches | The measurement is no longer clean; inspect setup branches, alignment, and `func_set_phr`. |
| Results are noisy across runs | Repeat measurements, pin to the same core, and avoid changing unrelated layout. |

## Current test structure

In `tb_full.S`:

- `_start` seeds a xorshift RNG and loops for about 100,000 iterations.
- `w0` carries the random bit `k`.
- `branch1` calls `func_set_phr`, aligns/pads the code, then executes `branch1_probe`.
- `branch2` calls `func_set_phr`, then executes `branch2_probe`.
- `branch1_probe` and `branch2_probe` use opposite conditions, so aliasing produces destructive interference.
- `func_set_phr` uses conditional branches on `k` to enter two targets placed 4 bytes apart, then executes a long unconditional branch chain before returning.

The linker script places relevant sections at fixed addresses, including separate high-address regions for `.phr`, `.br1`, and `.br2`. This is necessary because ordinary linking would not give stable branch PC bits across builds.

## Important caveats

- This is an aliasing experiment, not a direct readout of the PHT index function.
- A collision can disappear because of index bits, tag bits, BTB effects, frontend effects, or unintended history differences.
- A collision can persist even if a bit is used, depending on XOR/hash structure.
- Always verify actual probe addresses with `nm`; do not rely only on `.p2align` directives.
- Keep the same CPU core, loop count, linker layout, and PMU event when comparing runs.
- Treat `pht_tb`, `perf.data`, and `perf.data.old` as generated artifacts.

## Minimal reproduction

```bash
# Build
gcc -nostdlib -nostartfiles -ffreestanding -fno-pie -no-pie \
    -Wl,-Tlinker.ld -Wl,--build-id=none \
    -o pht_tb tb_full.S

# Check layout
nm -n pht_tb | grep -E '(_start|func_set_phr|branch1|branch2|branch1_probe|branch2_probe)'

# Measure rc5 mispredictions
taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ ./pht_tb

# Optional: collect sampled locations
taskset -c 4 perf record -c 10 -e apple_firestorm_pmu/rc5/ ./pht_tb
perf report
```

## Relation to the rest of the project

This experiment is part of the PHT indexing investigation. Other folders scan PHR/PHRT positions, associativity-like behavior, not-taken branch effects, and reverse probe ordering. This folder focuses specifically on whether two branches with controlled PC addresses and controlled history can be made to alias, then uses that aliasing behavior to infer candidate PC bits used by the predictor.
