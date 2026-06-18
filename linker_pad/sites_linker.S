    .text
    .align 2

    .section .text0, "ax"
    .global site_A
    .type site_A, %function
site_A:
    nop
    ret
    .size site_A, .-site_A

    .section .text1, "ax"
    .global site_B
    .type site_B, %function
site_B:
    nop
    ret
    .size site_B, .-site_B
