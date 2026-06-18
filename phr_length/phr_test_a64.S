    .text
    .global phr_test
    .type   phr_test, %function

    .extern global_sink

    .equ MAX_DUMMY, 256

phr_test:
    stp x29, x30, [sp, -16]!
    mov x29, sp
    stp x19, x20, [sp, -16]!
    stp x21, x22, [sp, -16]!

    mov x19, x0
    mov x20, x1

    cmp x20, #MAX_DUMMY
    b.ls 0f
    mov x20, #MAX_DUMMY
0:

    mov w21, #1

loop_top:
    cbz x19, loop_done

    mov  w22, w21
    eor  w22, w22, w22, lsl #13
    eor  w22, w22, w22, lsr #17
    eor  w22, w22, w22, lsl #5
    mov  w21, w22
    and  w22, w22, #1     // k in w22


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

    // Dummy unconditional taken branches:
    // jump to entry_dummy_count (inline, same function)
    adrp x13, dummy_jumptable
    add  x13, x13, :lo12:dummy_jumptable
    ldr  x14, [x13, x20, lsl #3]
    br   x14

dummy_done:
    // Probe conditional branch: if (k) {}
    // This should be the ONLY conditional path.
    cmp  w22, #0
    b.ne probe_taken
    // not taken
    nop
    b   probe_done
probe_taken:
    nop
probe_done:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    adrp x3, global_sink
    add  x3, x3, :lo12:global_sink
    ldr  w4, [x3]
    add  w4, w4, #1
    str  w4, [x3]

    subs x19, x19, #1
    b.ne loop_top

loop_done:
    ldp x21, x22, [sp], 16
    ldp x19, x20, [sp], 16
    ldp x29, x30, [sp], 16
    ret

    // Dummy jumptable + entries
    .align 3
dummy_jumptable:
    .include "phr_dummy.inc"

    .size phr_test, .-phr_test
