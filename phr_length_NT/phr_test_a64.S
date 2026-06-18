// phr_test_a64.S
// Paper-style PHR length microbenchmark (AArch64)
//
// For each iteration:
//   k = rand() & 1
//   indirect branch to (k ? L1 : L0)      // taken, randomized target
//   N unconditional dummy branches         // taken, unique PCs
//   if (k) {}                              // ONE conditional branch (probe)
//
// Measure apple_firestorm_pmu/rc5/ (cond mispred nonspec).
// Expect rc5/iter ~0 below threshold, ~0.5 beyond.

    .text
    .global phr_test
    .type   phr_test, %function

    .extern global_sink

    .equ MAX_DUMMY, 256

phr_test:
    // Prologue
    stp x29, x30, [sp, -16]!
    mov x29, sp
    stp x19, x20, [sp, -16]!
    stp x21, x22, [sp, -16]!

    mov x19, x0        // tries
    mov x20, x1        // dummy_count

    // Clamp dummy_count
    cmp x20, #MAX_DUMMY
    b.ls 0f
    mov x20, #MAX_DUMMY
0:

    mov w21, #1        // xorshift RNG state in w21 (non-zero)

loop_top:
    cbz x19, loop_done

    // ----------------------------
    // k = xorshift32() & 1
    // ----------------------------
    mov  w22, w21
    eor  w22, w22, w22, lsl #13
    eor  w22, w22, w22, lsr #17
    eor  w22, w22, w22, lsl #5
    mov  w21, w22
    and  w22, w22, #1     // k in w22

    // ----------------------------
    // Indirect branch with randomized target:
    //    br (k ? L1 : L0)
    // No conditional branch here.
    // ----------------------------
    adrp x10, L0
    add  x10, x10, :lo12:L0
    adrp x11, L1
    add  x11, x11, :lo12:L1

    cmp  w22, #0
    csel x12, x10, x11, eq   // if k==0 pick L0 else L1
    br   x12

L0:
    nop
L1:
    nop

    // ----------------------------
    // Dummy unconditional taken branches:
    // jump to entry_dummy_count (inline, same function)
    // ----------------------------
    adrp x13, dummy_jumptable
    add  x13, x13, :lo12:dummy_jumptable
    ldr  x14, [x13, x20, lsl #3]
    br   x14

dummy_done:
    // ----------------------------
    // Probe conditional branch: if (k) {}
    // This should be the ONLY conditional in the “core” path.
    // ----------------------------
    cmp  w22, #0
    b.ne probe_taken
    // not taken
    nop
    b   probe_done
probe_taken:
    nop
probe_done:

    // Touch global_sink (keep activity)
    adrp x3, global_sink
    add  x3, x3, :lo12:global_sink
    ldr  w4, [x3]
    add  w4, w4, #1
    str  w4, [x3]

    subs x19, x19, #1
    b.ne loop_top

loop_done:
    // Epilogue
    ldp x21, x22, [sp], 16
    ldp x19, x20, [sp], 16
    ldp x29, x30, [sp], 16
    ret

    // ------------------------------------------------------------
    // Dummy jumptable + entries (generated)
    // NOTE: include must appear AFTER dummy_done label is defined.
    // ------------------------------------------------------------
    .align 3
dummy_jumptable:
    .include "phr_dummy.inc"

    .size phr_test, .-phr_test
