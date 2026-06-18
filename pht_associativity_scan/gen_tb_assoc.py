import argparse


def emit_start(nbranches: int, iters: int = 100_000) -> str:
    lo = iters & 0xffff
    hi = (iters >> 16) & 0xffff

    calls = []
    for i in range(1, nbranches + 1):
        calls.append(f"""
    ldr     x16, =branch{i}
    blr     x16""")

    return f"""
    .text
    .align 2

.section .text.startup, "ax"
.global _start
.type _start, %function
_start:
    // RNG seed
    mov     w20, #0x1234
    movk    w20, #0xBEEF, lsl #16

    // N = {iters}
    mov     w19, #{lo:#x}
    movk    w19, #{hi:#x}, lsl #16

1:  // xorshift32
    eor     w20, w20, w20, lsl #13
    eor     w20, w20, w20, lsr #17
    eor     w20, w20, w20, lsl #5

    // k = x & 1
    and     w0, w20, #1

    // Active probe branches: {nbranches}
{''.join(calls)}

    subs    w19, w19, #1
    b.ne    1b

    // exit(0)
    mov     x0, #0
    mov     x8, #93
    svc     #0
.size _start, .-_start
.ltorg
"""


def emit_branch_macro(max_branches: int) -> str:
    instances = []
    for i in range(1, max_branches + 1):
        instances.append(f"MAKE_BRANCH branch{i}, {i - 1}")

    return f"""
// Branch generator macro
.macro MAKE_BRANCH name, pad_nops
    .section .\\name, "ax"
    .global \\name
    .type \\name, %function
\\name:
    stp     x29, x30, [sp, -16]!
    mov     x29, sp

    ldr     x16, =func_set_phr
\\name\\()_setFunction:
    blr     x16

\\name\\()_after_set:
    .rept   \\pad_nops
    nop
    .endr

\\name\\()_probe:
    cmp     w0, #0
    b.eq    \\name\\()_taken

\\name\\()_fall:
    ldp     x29, x30, [sp], 16
    ret

\\name\\()_taken:
    ldp     x29, x30, [sp], 16
    ret

    .size \\name, .-\\name
.endm

// Probe PCs differ by +4 each.
{chr(10).join(instances)}

.ltorg
"""


def emit_k_injection_normal(next_target: str) -> str:
    """
    Original compact injection.
    """
    if next_target == "ret":
        after0 = "    ret"
        after1 = "    ret"
    else:
        after0 = f"    b       {next_target}"
        after1 = f"    b       {next_target}"

    return f"""
    // flags from k
    cmp     w0, #0

    // exactly one of these is taken
    b.eq    .L0_inject
    b.ne    .L1_inject

    .p2align 2

.L0_inject:
{after0}

.L1_inject:
{after1}
"""


def emit_k_injection_zero_phrb(next_label: str) -> str:
    """
    PHRB-clean injection.
    """
    if next_label == "ret":
        raise ValueError(
            "zero_phrb injection cannot target ret directly; "
            "inject_after must be < total_labels"
        )

    return f"""
    // flags from k
    cmp     w0, #0

    // Align each taken conditional branch PC so PHRB gets branch_PC[5:2] = 0.
    .p2align 6
    b.eq    .L0_inject

    .p2align 6
    b.ne    .L1_inject

    // Targets must be 4B apart so PHRT target[2] differs with k.
    .p2align 6
.L0_inject:
    nop
.L1_inject:
    nop

    // Fall through into the next dummy branch.
    // This branch PC is also 64B-aligned, so PHRB gets 0.
    .p2align 6
{next_label}:
"""


def emit_phr(
    inject_after: int,
    total_labels: int = 99,
    zero_phrb: bool = False,
) -> str:
    """
    Generate func_set_phr with injection slots 0..total_labels.

    Current intended 100-history setup:
      total_labels = 98
      inject_after = 0..98

    With zero_phrb=False, labels are compact.

    With zero_phrb=True:
      - every dummy branch instruction is 64B-aligned
      - the k injection uses aligned b.eq/b.ne PCs
      - .L0_inject/.L1_inject remain 4B apart as PHRT targets
      - the injection falls through into the next dummy label

    Mapping if ret counts:
      phr_pos ≈ total_labels + 1 - inject_after
      for total_labels=98:
        inject_after=0  -> PHRT[99]
        inject_after=98 -> PHRT[1]
    """

    if inject_after < 0 or inject_after > total_labels:
        raise ValueError(f"inject_after must be in [0, {total_labels}]")

    if zero_phrb and inject_after == total_labels:
        raise ValueError(
            "error"
        )

    lines = []
    lines.append("""
.section .phr, "ax"
.global func_set_phr
.type func_set_phr, %function
func_set_phr:
""")

    if inject_after == 0:
        if zero_phrb:
            lines.append(emit_k_injection_zero_phrb(".Llabel1"))
        else:
            lines.append(emit_k_injection_normal(".Llabel1"))
    else:
        if zero_phrb:
            lines.append("    .p2align 6")
        lines.append("    b       .Llabel1")

    for i in range(1, total_labels + 1):
        if i == inject_after:
            if zero_phrb:
                lines.append(f".Llabel{i}:")
                lines.append(emit_k_injection_zero_phrb(f".Llabel{i + 1}"))
            else:
                lines.append(f".Llabel{i}:")
                if i < total_labels:
                    lines.append(emit_k_injection_normal(f".Llabel{i + 1}"))
                else:
                    lines.append(emit_k_injection_normal("ret"))

        else:
            if zero_phrb and i == inject_after + 1:
                pass
            else:
                if zero_phrb:
                    lines.append("    .p2align 6")
                lines.append(f".Llabel{i}:")

            if i < total_labels:
                lines.append(f"    b       .Llabel{i + 1}")
            else:
                lines.append("    ret")

    lines.append(".size func_set_phr, .-func_set_phr")
    return "\n".join(lines)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--inject-after", type=int, required=True)
    ap.add_argument("--nbranches", type=int, required=True)
    ap.add_argument("--max-branches", type=int, default=8)
    ap.add_argument("--total-labels", type=int, default=99)
    ap.add_argument("--iters", type=int, default=100_000)
    ap.add_argument(
        "--zero-phrb",
        action="store_true",
        help="Align taken branch PCs in func_set_phr so PHRB receives zeros."
    )
    ap.add_argument("-o", "--output", default="tb_auto.S")
    args = ap.parse_args()

    if args.nbranches < 1 or args.nbranches > args.max_branches:
        raise SystemExit("--nbranches must be between 1 and --max-branches")

    asm = []
    asm.append(emit_start(args.nbranches, args.iters))
    asm.append(emit_branch_macro(args.max_branches))
    asm.append(
        emit_phr(
            args.inject_after,
            args.total_labels,
            zero_phrb=args.zero_phrb,
        )
    )

    with open(args.output, "w") as f:
        f.write("\n".join(asm))


if __name__ == "__main__":
    main()