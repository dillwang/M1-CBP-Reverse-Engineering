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
    movz    w20, #0x1234
    movk    w20, #0xBEEF, lsl #16

    // loop counter
    # movz    w19, #0x4240
    # movk    w19, #0x000F, lsl #16
    
    movz    w19, #0x86A0
    movk    w19, #0x0001, lsl #16

for_loop:
    eor     w20, w20, w20, lsl #13
    eor     w20, w20, w20, lsr #17
    eor     w20, w20, w20, lsl #5

    and     w21, w20, #1

    mov     w15, #102

    ldr     x16, =L_jump_clear
    br      x16



    .section .text.main, "ax"

    .global L_target_clear
L_target_clear:
    sub     w15, w15, #1

    .p2align 19

    .global L_jump_clear
L_jump_clear:
    cbnz    w15, L_target_clear



after_clear:
    cmp     w21, #0

    .p2align 10

    .global Train_Branch
Train_Branch:
    b.eq    lbl_tr

    .p2align 19
lbl_tr:
    nop


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