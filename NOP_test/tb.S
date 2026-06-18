    .section .text
    .global _start
    .type _start, %function

/* ===== edit ===== */
    .equ ALIGN_POW, 19
    .equ ITERS,     1000000

_start:
    movz    x1, #0x5678
    movk    x1, #0x1234, lsl #16

    movz x2, #0x86A0
    movk x2, #0x0001, lsl #16

loop:
    eor     x1, x1, x1, lsl #13
    eor     x1, x1, x1, lsr #7
    eor     x1, x1, x1, lsl #17

    and     w3, w1, #1

    .p2align ALIGN_POW

    cmp     w3, #0
    b    L1

    nop

L1:
    subs    x2, x2, #1
    b.ne    loop

    mov     x0, #0
    mov     x8, #93
    svc     #0

    .size _start, .-_start