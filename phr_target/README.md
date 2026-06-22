# phr_target

Target-history PHR experiment using two linker-placed indirect-call targets.

This benchmark tests whether the branch predictor history used by a later conditional probe is affected by the target address of an earlier indirect call. The two possible targets, `L0` and `L1`, are placed exactly `2^bit` bytes apart by a generated linker script.

## Files

| File | Purpose |
|---|---|
| `build_bits.sh` | Builds one binary per target-distance bit by generating `link.ld`. |
| `tb.c` | Runtime driver for `run_target_ld(iters, seed, ndummy)`. |
| `tb.S` | Main benchmark loop: indirect call to `L0`/`L1`, dummy branch chain, conditional probe. |
| `targets.S` | Defines `L0` and `L1` in `.tgt0` and `.tgt1` sections. |
| `link.ld` | Generated linker script from the most recent `build_bits.sh` run. |

## Benchmark structure

Per iteration:

```text
k = xorshift32() & 1

if k == 0:
    indirect call target = L0
else:
    indirect call target = L1

N dummy unconditional branches

probe conditional branch based on k
```

`L0` and `L1` simply return. The point is not their behavior, but the target address difference observed by the predictor.

## Build binaries for a bit range

```bash
chmod +x build_bits.sh
./build_bits.sh 2 16
```

This builds:

```text
firestorm_target_ld_b2
firestorm_target_ld_b3
...
firestorm_target_ld_b16
```

For each bit `b`, `build_bits.sh` generates `link.ld` so that:

```text
L1 - L0 = 2^b bytes
```

The script places `.tgt0` on a page boundary and `.tgt1` exactly `2^b` bytes after `.tgt0`.

## Run one binary

```bash
taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ \
    ./firestorm_target_ld_b16 100 2000000 1
```

Arguments:

```text
./firestorm_target_ld_b<bit> <ndummy> <iters> [seed]
```

- `ndummy`: number of dummy unconditional branches, `0..160`.
- `iters`: number of benchmark iterations.
- `seed`: optional xorshift seed, default `1`.

## Suggested manual sweep

This folder does not currently include a dedicated sweep script. A simple loop is:

```bash
echo "bit,ndummy,iters,rc5" > results.csv

for b in $(seq 2 16); do
  bin="./firestorm_target_ld_b${b}"
  for n in $(seq 65 100); do
    rc5=$(
      taskset -c 4 perf stat -x, -e apple_firestorm_pmu/rc5/ \
        "$bin" "$n" 2000000 1 \
        2>&1 >/dev/null |
      awk -F, '/apple_firestorm_pmu\/rc5\// {gsub(/ /,"",$1); print $1; exit}'
    )
    echo "$b,$n,2000000,$rc5" >> results.csv
  done
done
```

## Interpretation

- If changing the `L0`/`L1` distance bit changes the probe branch's `rc5`, that target-address bit may contribute to the predictor history or indexing path used by the later conditional branch.
- Sweeping `ndummy` tests how long the target-derived information survives before the probe.
- A flat result across bits suggests the tested target bit is not relevant under the current layout or that the signal is masked by other predictor state.

## Notes

- `build_bits.sh` defaults to `2..16`, but accepts any range you pass.
- Large target distances can become sensitive to linker layout and relocation constraints. Inspect with `nm -n` or `objdump -d` if results look strange.
- `phr_target_indirect` is a more automated related folder with a sweep script and CSV generation.
