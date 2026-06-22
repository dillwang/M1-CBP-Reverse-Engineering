# linker_pad

Minimal linker-script experiment for placing two code sites at controlled virtual addresses.

The goal is to verify that the linker can place `site_A` and `site_B` in separate executable regions with controlled low address bits. This was used as infrastructure for later branch-predictor experiments that require two branch or target PCs to differ by a specific address bit.

## Files

| File | Purpose |
|---|---|
| `two_text_segments.ld` | Linker script that creates two RX load segments: `.text0` and `.text1`. |
| `start_and_sites.S` | Standalone `_start` program that prints the addresses of `site_A`, `site_B`, and their difference using Linux syscalls. |
| `sites_linker.S` | Simple `site_A` / `site_B` functions in `.text0` and `.text1`. |
| `main_linker.cpp` | C++ version that checks whether both sites have low 32 bits equal to zero and whether the distance is 4 GiB. |
| `Scripts.txt` | Original build and inspection commands. |

## What this tests

`two_text_segments.ld` places:

```text
.text0 at 0x0000000100000000
.text1 at 0x0000000200000000
```

Therefore `site_B - site_A` should be `0x100000000`, or 4 GiB, when the sections are placed as intended.

This is useful when checking whether predictor indexing uses low PC bits only, or whether higher address bits can influence aliasing.

## Build standalone syscall version

```bash
gcc -O2 -fno-pie -no-pie -nostdlib -nostartfiles \
    -Wl,-T,two_text_segments.ld -Wl,--build-id=none \
    -Wl,--gc-sections \
    -o bench_linker start_and_sites.S
```

## Inspect addresses

```bash
readelf -h bench_linker | egrep 'Type:|Entry'
readelf -lW bench_linker | egrep 'LOAD|Entry'
readelf -sW bench_linker | egrep 'site_A|site_B|_start'
```

## Run

```bash
./bench_linker
```

Expected output format:

```text
A=0x...
B=0x...
D=0x...
```

`D` should be `0x0000000100000000` if the 4 GiB placement worked.

## Optional C++ check

The repository also includes `main_linker.cpp`, which checks:

```text
low32(site_A) == 0
low32(site_B) == 0
site_B - site_A == 4 GiB
```

A possible build flow is:

```bash
g++ -O2 -fno-pie -no-pie \
    main_linker.cpp sites_linker.S \
    -Wl,-T,two_text_segments.ld \
    -o bench_linker_cpp

./bench_linker_cpp
```

## Notes

- The standalone version avoids libc and directly uses `write` and `exit` syscalls.
- Large fixed virtual addresses can be sensitive to linker flags and loader behavior. Keep `-fno-pie -no-pie` when you want predictable addresses.
- This folder is mainly infrastructure. It does not measure branch prediction by itself.
