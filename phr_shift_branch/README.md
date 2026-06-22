# phr_shift_branch

Differential PHR footprint test that toggles a selected branch-PC bit and checks whether the later probe branch sees a different predictor-history state.

The benchmark generates a pair of conditional/unconditional injection branches whose PCs are separated by `2^bit` bytes. It then executes a configurable number of dummy unconditional branches before a conditional probe.

## Files

| File | Purpose |
|---|---|
| `tb.c` | C driver. Selects which generated assembly function to run based on the `bit` argument. |
| `tb.S` | AArch64 benchmark generator using `GEN_FUNC` macros for multiple bit positions. |
| `script.txt` | Original build and simple sweep commands. |
| `firestorm_phr_heatmap.py` | Plot helper for heatmap CSVs with columns such as `bit`, `ndummy`, `iters`, `rc5`, `miss_per_iter`. |
| `firestorm_heat.csv` | Existing manually collected or generated heatmap data, if present. |

## Benchmark structure

For each iteration:

```text
k = xorshift32() & 1

Injection pair:
    b.ne L0         // taken when k = 1
    padding
    b    L0         // taken when k = 0

N dummy unconditional branches

Probe:
    b.ne probe_tgt  // uses the same flags from k
```

For a selected `bit`, the assembly aligns and pads the injection sites so the two relevant branch PCs differ by `2^bit`.

## Build

```bash
gcc -O2 tb.c tb.S -o firestorm_phr_tb
```

## Run one point

```bash
taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ \
    ./firestorm_phr_tb 10 80 2000000 0x12345678
```

Arguments:

```text
./firestorm_phr_tb <bit> <ndummy> [iters] [seed]
```

- `bit`: target PC bit to toggle.
- `ndummy`: dummy branch count, `0..160`.
- `iters`: defaults to `2000000`.
- `seed`: defaults to `0x12345678`.

## Simple sweep

The original script builds the binary and sweeps:

```bash
gcc -O2 tb.c tb.S -o firestorm_phr_tb

for b in $(seq 2 18); do
  echo "bit=$b"
  taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ \
      ./firestorm_phr_tb "$b" 0 2000000
done
```

Note: `tb.c`'s usage string says `2..20`, but the current switch only handles bits `2..18`, and `tb.S` currently instantiates `run_inject_bit2` through `run_inject_bit18`. Use `2..18` unless you add more cases.

## Plot existing CSV

If you have a CSV with columns like:

```text
bit,ndummy,iters,rc5,miss_per_iter
```

then run:

```bash
python3 firestorm_phr_heatmap.py \
    --csv firestorm_heat.csv \
    --out firestorm_target_heatmap \
    --dummy-overhead 2 \
    --bit-min 2 \
    --bit-max 18
```

This writes:

```text
firestorm_target_heatmap.png
```

## Interpretation

- A high `rc5 / iter` region indicates the probe becomes harder to predict for that injected bit and dummy distance.
- If toggling a particular branch-PC bit affects the probe, that bit may contribute to the predictor history representation or indexing path used by the later branch.
- The dummy sweep dimension checks how long the injected distinction survives.

## Notes

- The dummy chain contains 160 unconditional branches.
- The probe relies on flags from the earlier `tst w11, w11`; the intervening dummy branches are unconditional and preserve flags.
- This is sensitive to code layout. Rebuilds, compiler flags, and alignment changes can move results.
