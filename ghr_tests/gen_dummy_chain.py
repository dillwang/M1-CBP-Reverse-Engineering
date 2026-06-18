#!/usr/bin/env python3
import sys

MAX_DUMMY = 256  # change to 512 if you want more range

out = []
out.append("// auto-generated dummy_chain_a64.S (GAS/AArch64)\n")
out.append(".text\n")
out.append(".global dummy_chain\n")
out.append(".type   dummy_chain, %function\n")
out.append(f".equ MAX_DUMMY, {MAX_DUMMY}\n\n")

out.append("// void dummy_chain(long n)\n")
out.append("// x0 = n (0..MAX_DUMMY)\n")
out.append("dummy_chain:\n")
out.append("    // clamp n\n")
out.append("    cmp x0, #MAX_DUMMY\n")
out.append("    b.ls 1f\n")
out.append("    mov x0, #MAX_DUMMY\n")
out.append("1:\n")
out.append("    // jump via table\n")
out.append("    adrp x1, dummy_jumptable\n")
out.append("    add  x1, x1, :lo12:dummy_jumptable\n")
out.append("    ldr  x2, [x1, x0, lsl #3]\n")
out.append("    br   x2\n\n")

out.append(".align 3\n")
out.append("dummy_jumptable:\n")
for n in range(MAX_DUMMY + 1):
    out.append(f"    .8byte entry_{n}\n")
out.append("\n")

out.append(".align 4\n")
out.append("entry_0:\n")
out.append("    ret\n\n")

for n in range(1, MAX_DUMMY + 1):
    out.append(".align 4\n")
    out.append(f"entry_{n}:\n")
    out.append(f"    .rept {n}\n")
    out.append("        cmp xzr, xzr\n")
    out.append("        b.eq 1f\n")
    out.append("    1:\n")
    out.append("    .endr\n")
    out.append("    ret\n\n")

out.append(".size dummy_chain, .-dummy_chain\n")

sys.stdout.write("".join(out))
