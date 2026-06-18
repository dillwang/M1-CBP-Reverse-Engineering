    .section .text.startup, "ax"
    .global _start
    .type _start, %function
_start:
    mov     w15, #100
    b       L_jump

    .section .text.phr_target, "ax"
    .global L_target
L_target:
    sub     w15, w15, #1

    .p2align 10, 0xD503201F 
    .global L_jump
L_jump:
    cbnz    w15, L_target

    mov     x0, #0
    mov     x8, #93
    svc     #0