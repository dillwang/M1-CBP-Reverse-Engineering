// tb.S
// Minimal AArch64 GAS microbenchmark
//
// Structure:
//   for 100000 iterations:
//       k = xorshift32() & 1
//       cmp k, 1
//       b.eq L0
//       .p2align ...
//       b.ne L0
//   L0:
//       30 dummy unconditional jumps
//       b.ne probe_tgt     // same flags from cmp
//
// Build:
//   gcc -nostdlib -nostartfiles -ffreestanding -Wl,--build-id=none -o tb tb.S
//
// Run:
//   taskset -c 4 perf stat -e apple_firestorm_pmu/<event>/ ./tb

    .text
    .arch armv8-a
    .align 2
    .global _start


    .macro XORSHIFT32
    eor     w10, w10, w10, lsl #13
    eor     w10, w10, w10, lsr #17
    eor     w10, w10, w10, lsl #5
    and     w11, w10, #1
    .endm

_start:
    // x19 = iteration count = 100000 = 0x186A0
    movz    x19, #0x86A0
    movk    x19, #0x0001, lsl #16

    // w10 = xorshift seed = 0x12345678
    movz    w10, #0x5678
    movk    w10, #0x1234, lsl #16

loop:
    // k = xorshift32() & 1
    XORSHIFT32

    // Set flags from k compared against 1
    cmp     w11, #1

    // First conditional branch
branch_a:
    b.eq    L0

    .rept 256
    nop
    .endr
    #.p2align 10, 0xD503201F

branch_b:
    b.ne    L0

L0:
    // 30 dummy unconditional jumps
    b      L_d0
L_d0:  b   L_d1
L_d1:  b   L_d2
L_d2:  b   L_d3
L_d3:  b   L_d4
L_d4:  b   L_d5
L_d5:  b   L_d6
L_d6:  b   L_d7
L_d7:  b   L_d8
L_d8:  b   L_d9
L_d9:  b   L_d10
L_d10: b   L_d11
L_d11: b   L_d12
L_d12: b   L_d13
L_d13: b   L_d14
L_d14: b   L_d15
L_d15: b   L_d16
L_d16: b   L_d17
L_d17: b   L_d18
L_d18: b   L_d19
L_d19: b   L_d20
L_d20: b   L_d21
L_d21: b   L_d22
L_d22: b   L_d23
L_d23: b   L_d24
L_d24: b   L_d25
L_d25: b   L_d26
L_d26: b   L_d27
L_d27: b   L_d28
L_d28: b   L_d29
L_d29: b   after_dummies

after_dummies:
    // Probe branch using same flags from cmp w11, #1
    // Since only unconditional branches were in between, NZCV is preserved.
    b.ne    probe_tgt
    nop
probe_tgt:

    subs    x19, x19, #1
    b.ne    loop

    // exit(0)
    mov     x0, #0
    mov     x8, #93
    svc     #0