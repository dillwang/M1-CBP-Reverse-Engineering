#!/usr/bin/env python3
"""
python3 sweep_firestorm_target_bits.py \
    --linker linker.ld \
    --core 4 \
    --event apple_firestorm_pmu/rc5/ \
    --outdir sweep_out
- The default x-axis sweep is 67..100 inclusive.
- The default y-axis sweep is 2..19 inclusive.
- If you want 67..101 instead, pass `--jump-max 101`.
"""

from __future__ import annotations

import argparse
import csv
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np


ASM_HEADER = r"""
    .arch armv8-a

    .set LOOP_ITERS,              1000000
    .set CLEAR_JUMP_OFF,          0x400
    .set TRAIN_BRANCH_OFF,        0x800
    .set TEST_OFF,                0xC00
    .set TAIL_OFF,                0x1000

    .section .text.init, "ax"
    .global _start
    .type   _start, %function

_start:
    // RNG seed
    movz    w20, #0x1234
    movk    w20, #0xBEEF, lsl #16

    // loop counter
    movz    w19, #0x86A0
    movk    w19, #0x0001, lsl #16

for_loop:
    // xorshift32
    eor     w20, w20, w20, lsl #13
    eor     w20, w20, w20, lsr #17
    eor     w20, w20, w20, lsl #5

    // random bit in w21
    and     w21, w20, #1

    // CLEAR #
    mov     w15, #102

    // clear loop body
    ldr     x16, =L_jump_clear
    br      x16

    .section .text.main, "ax"

    // CLEAR_PHR
    .global L_target_clear
L_target_clear:
    sub     w15, w15, #1

    .p2align {ALIGN_BITS}

    .global L_jump_clear
L_jump_clear:
    cbnz    w15, L_target_clear

after_clear:
    cmp     w21, #0

    .p2align {ALIGN_BITS}

    .global Train_Branch
Train_Branch:
    b.eq    lbl_tr

    .p2align {ALIGN_BITS}
lbl_tr:
    nop

    bl      Do_Uncond_Jumps

Label_Test1:
    b.eq    lbl_ts1

lbl_ts1:
    nop

Tail1:
    subs    w19, w19, #1
    b.eq    done

    ldr     x16, =for_loop
    br      x16

done:
    mov     x0, #0
    mov     x8, #93
    svc     #0

    .section .text.uncond_jumps, "ax"
    .global Do_Uncond_Jumps
    .type   Do_Uncond_Jumps, %function
Do_Uncond_Jumps:
"""

ASM_FOOTER = "\n"


def generate_jump_chain(num_jumps: int) -> str:
    """

    Example for num_jumps=3:
        b uj_001
    uj_001: b uj_002
    uj_002: b uj_003
    uj_003: ret
    """
    if num_jumps < 1:
        raise ValueError("num_jumps must be >= 1")

    lines = []
    lines.append("    b       uj_001")
    for i in range(1, num_jumps):
        lines.append(f"uj_{i:03d}:")
        lines.append(f"    b       uj_{i+1:03d}")
    lines.append(f"uj_{num_jumps:03d}:")
    lines.append("    ret")
    return "\n".join(lines) + "\n"


def generate_asm(align_bits: int, num_jumps: int) -> str:
    body = ASM_HEADER.format(ALIGN_BITS=align_bits)
    body += generate_jump_chain(num_jumps)
    body += ASM_FOOTER
    return body


def run_cmd(cmd: list[str], cwd: Path | None = None, check: bool = True) -> subprocess.CompletedProcess:
    return subprocess.run(
        cmd,
        cwd=str(cwd) if cwd else None,
        text=True,
        capture_output=True,
        check=check,
    )


def parse_perf_count(stderr_text: str, event_name: str) -> int:
    """
    Parse `perf stat -x,` output.
    """
    for line in stderr_text.splitlines():
        if event_name in line:
            first = line.split(",")[0].strip()
            first = first.replace(".", "")
            if first in ("<not counted>", "<not supported>"):
                raise RuntimeError(f"perf did not count event {event_name}: {line}")
            try:
                return int(first)
            except ValueError:
                pass

    raise RuntimeError(f"Could not parse perf output for event {event_name}.\nperf stderr was:\n{stderr_text}")


def build_one(
    workdir: Path,
    asm_path: Path,
    bin_path: Path,
    linker_path: Path,
    gcc_bin: str,
) -> None:
    cmd = [
        gcc_bin,
        "-nostdlib",
        "-nostartfiles",
        "-ffreestanding",
        "-fno-pie",
        "-no-pie",
        "-Wl,-T" + str(linker_path),
        "-Wl,--build-id=none",
        "-o",
        str(bin_path),
        str(asm_path),
    ]
    result = run_cmd(cmd, cwd=workdir, check=False)
    if result.returncode != 0:
        raise RuntimeError(
            "Build failed.\n"
            f"Command: {' '.join(cmd)}\n\n"
            f"stdout:\n{result.stdout}\n\n"
            f"stderr:\n{result.stderr}"
        )


def run_one(
    bin_path: Path,
    core: int,
    event_name: str,
    perf_bin: str,
    taskset_bin: str,
) -> int:
    cmd = [
        taskset_bin,
        "-c",
        str(core),
        perf_bin,
        "stat",
        "-x,",
        "-e",
        event_name,
        str(bin_path),
    ]
    result = run_cmd(cmd, check=False)
    if result.returncode != 0:
        raise RuntimeError(
            "Run/perf failed.\n"
            f"Command: {' '.join(cmd)}\n\n"
            f"stdout:\n{result.stdout}\n\n"
            f"stderr:\n{result.stderr}"
        )
    return parse_perf_count(result.stderr, event_name)


def make_heatmap(
    csv_rows: list[dict[str, float | int]],
    align_values: list[int],
    jump_values: list[int],
    out_png: Path,
    title: str,
) -> None:
    arr = np.full((len(align_values), len(jump_values)), np.nan, dtype=float)

    align_to_row = {v: i for i, v in enumerate(align_values)}
    jump_to_col = {v: i for i, v in enumerate(jump_values)}

    for row in csv_rows:
        ai = align_to_row[int(row["align_bits"])]
        ji = jump_to_col[int(row["num_jumps"])]
        arr[ai, ji] = float(row["rc5_per_iter"])

    fig, ax = plt.subplots(figsize=(16, 9))
    im = ax.imshow(arr, aspect="auto", origin="upper")

    ax.set_title(title)
    ax.set_xlabel("Dummy unconditional jumps")
    ax.set_ylabel("Shared .p2align bits")

    ax.set_xticks(np.arange(len(jump_values)))
    ax.set_xticklabels(jump_values, rotation=90)

    ax.set_yticks(np.arange(len(align_values)))
    ax.set_yticklabels(align_values)

    ax.grid(which="major", color="#b0b0b0", linewidth=1.0)
    ax.set_xticks(np.arange(-0.5, len(jump_values), 1), minor=True)
    ax.set_yticks(np.arange(-0.5, len(align_values), 1), minor=True)
    ax.grid(which="minor", color="#b0b0b0", linewidth=1.0)
    ax.tick_params(which="minor", bottom=False, left=False)

    cbar = plt.colorbar(im, ax=ax)
    cbar.set_label("rc5 / iter")

    plt.tight_layout()
    plt.savefig(out_png, dpi=200)
    plt.close(fig)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--align-min", type=int, default=2)
    parser.add_argument("--align-max", type=int, default=19)
    parser.add_argument("--jump-min", type=int, default=67)
    parser.add_argument("--jump-max", type=int, default=100)
    parser.add_argument("--loop-iters", type=int, default=1_000_000, help="Only used for normalization label/checks.")
    parser.add_argument("--core", type=int, default=4)
    parser.add_argument("--event", default="apple_firestorm_pmu/rc5/")
    parser.add_argument("--outdir", default="sweep_out")
    parser.add_argument("--linker", required=True, help="Path to your linker script, e.g. linker.ld")
    parser.add_argument("--gcc", default="gcc")
    parser.add_argument("--perf", default="perf")
    parser.add_argument("--taskset", default="taskset")
    parser.add_argument("--keep-binaries", action="store_true")
    args = parser.parse_args()

    for tool in (args.gcc, args.perf, args.taskset):
        if shutil.which(tool) is None:
            print(f"ERROR: Required tool not found in PATH: {tool}", file=sys.stderr)
            return 1

    linker_path = Path(args.linker).resolve()
    if not linker_path.exists():
        print(f"ERROR: Linker script not found: {linker_path}", file=sys.stderr)
        return 1

    outdir = Path(args.outdir).resolve()
    asm_dir = outdir / "asm"
    bin_dir = outdir / "bin"
    outdir.mkdir(parents=True, exist_ok=True)
    asm_dir.mkdir(parents=True, exist_ok=True)
    if args.keep_binaries:
        bin_dir.mkdir(parents=True, exist_ok=True)

    align_values = list(range(args.align_min, args.align_max + 1))
    jump_values = list(range(args.jump_min, args.jump_max + 1))

    rows: list[dict[str, float | int]] = []

    total = len(align_values) * len(jump_values)
    idx = 0

    for align_bits in align_values:
        for num_jumps in jump_values:
            idx += 1
            tag = f"a{align_bits:02d}_j{num_jumps:03d}"
            asm_path = asm_dir / f"tb_{tag}.S"
            bin_path = (bin_dir if args.keep_binaries else outdir) / f"tb_{tag}"

            asm_text = generate_asm(align_bits, num_jumps)
            asm_path.write_text(asm_text)

            print(f"[{idx}/{total}] build/run align={align_bits}, jumps={num_jumps}")
            build_one(outdir, asm_path, bin_path, linker_path, args.gcc)
            rc5 = run_one(bin_path, args.core, args.event, args.perf, args.taskset)
            rc5_per_iter = rc5 / float(args.loop_iters)

            rows.append(
                {
                    "align_bits": align_bits,
                    "num_jumps": num_jumps,
                    "rc5": rc5,
                    "rc5_per_iter": rc5_per_iter,
                }
            )

            if not args.keep_binaries:
                try:
                    bin_path.unlink()
                except FileNotFoundError:
                    pass

    csv_path = outdir / "results.csv"
    with csv_path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["align_bits", "num_jumps", "rc5", "rc5_per_iter"])
        writer.writeheader()
        writer.writerows(rows)

    png_path = outdir / "heatmap.png"
    make_heatmap(
        rows,
        align_values=align_values,
        jump_values=jump_values,
        out_png=png_path,
        title=f"Firestorm rc5 sweep | align bits={args.align_min}..{args.align_max}, jumps={args.jump_min}..{args.jump_max}",
    )

    print(f"\nDone.")
    print(f"CSV:     {csv_path}")
    print(f"Heatmap: {png_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
