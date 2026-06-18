
    .section .tgt0, "ax"
    .align 2
    .global L0
    .type L0, %function
L0:
    ret
    .size L0, .-L0

    .section .tgt1, "ax"
    .align 2
    .global L1
    .type L1, %function
L1:
    ret
    .size L1, .-L1
