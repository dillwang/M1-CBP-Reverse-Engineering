    .text
    .align 2

.section .text.startup, "ax"
.global _start
.type _start, %function
_start:
    mov     w20, #0x1234
    movk    w20, #0xBEEF, lsl #16

    // N = 100,000
    # mov     w19, #0x86A0
    # movk    w19, #0x0001, lsl #16

    // tries = 1,000,000
    movz w19, #0x4240
    movk w19, #0xF, lsl #16

    mov     w1, #0
#    mov     w2, #0
#    mov     w3, #0


1:
    eor     w20, w20, w20, lsl #13
    eor     w20, w20, w20, lsr #17
    eor     w20, w20, w20, lsl #5

    // k = x & 1
    and     w0, w20, #1

    // Call branch1
    ldr x16, =branch1
    blr x16

    // Call branch2
    ldr     x16, =branch2
    blr     x16

    subs    w19, w19, #1
    b.ne    1b

    mov     x0, #0
    mov     x8, #93
    svc     #0
.size _start, .-_start
.ltorg


.section .br1, "ax"
.global branch1
.type branch1, %function
branch1:
    stp     x29, x30, [sp, -16]!
    mov     x29, sp

    # ldr x16, =func_set_phr
    adrp    x16, func_set_phr
    add     x16, x16, :lo12:func_set_phr
branch1_setFunction:
    blr x16

    .p2align 9

branch1_nt:
    // Not taken branch
    cbz w1, first_iteration_1
    # cbz w1, nt_fall_1
nt_fall_1:
#    cbz w2, first_iteration_2
# nt_fall_2:
#    cbz w3, first_iteration_3
    nop
    nop

branch1_probe:
    cmp     w0, #0
    b.ne    branch1_taken

branch1_fall:
    ldp     x29, x30, [sp], 16
    ret

branch1_taken:
    ldp     x29, x30, [sp], 16
    ret

first_iteration_1:
    // set w1 to 1 so the later ones are all not taken branches
    mov     w1, #1
    b       nt_fall_1
# first_iteration_2:
#    mov     w2, #1
#    b       nt_fall_2
# first_iteration_3:
#    mov     w3, #1
#   b       branch1_probe
.size branch1, .-branch1



.section .br2, "ax"
.global branch2
.type branch2, %function
branch2:
    stp     x29, x30, [sp, -16]!
    mov     x29, sp

    # ldr     x16, =func_set_phr
    adrp    x16, func_set_phr
    add     x16, x16, :lo12:func_set_phr
branch2_setFunction:
    blr     x16

    .p2align 9
    nop
    nop
    nop

branch2_probe:
    cmp     w0, #0
    b.eq    branch2_taken

branch2_fall:
    ldp     x29, x30, [sp], 16
    ret

branch2_taken:
    ldp     x29, x30, [sp], 16
    ret
.size branch2, .-branch2


.section .phr, "ax"
.global func_set_phr
.type func_set_phr, %function
func_set_phr:
    // flags from k
    cmp     w0, #0

    b.eq    L0_inject
    b.ne    L1_inject
    
    .p2align 2
    // 4 bytes apart
L0_inject:
    b       .Llabel1
L1_inject:
    b       .Llabel1

    // unconditional branches
.Llabel1:  b .Llabel2
.Llabel2:  b .Llabel3
.Llabel3:  b .Llabel4
.Llabel4:  b .Llabel5
.Llabel5:  b .Llabel6
.Llabel6:  b .Llabel7
.Llabel7:  b .Llabel8
.Llabel8:  b .Llabel9
.Llabel9:  b .Llabel10
.Llabel10: b .Llabel11
.Llabel11: b .Llabel12
.Llabel12: b .Llabel13
.Llabel13: b .Llabel14
.Llabel14: b .Llabel15
.Llabel15: b .Llabel16
.Llabel16: b .Llabel17
.Llabel17: b .Llabel18
.Llabel18: b .Llabel19
.Llabel19: b .Llabel20
.Llabel20: b .Llabel21
.Llabel21: b .Llabel22
.Llabel22: b .Llabel23
.Llabel23: b .Llabel24
.Llabel24: b .Llabel25
.Llabel25: b .Llabel26
.Llabel26: b .Llabel27
.Llabel27: b .Llabel28
.Llabel28: b .Llabel29
.Llabel29: b .Llabel30
.Llabel30: b .Llabel31
.Llabel31: b .Llabel32
.Llabel32: b .Llabel33
.Llabel33: b .Llabel34
.Llabel34: b .Llabel35
.Llabel35: b .Llabel36
.Llabel36: b .Llabel37
.Llabel37: b .Llabel38
.Llabel38: b .Llabel39
.Llabel39: b .Llabel40
.Llabel40: b .Llabel41
.Llabel41: b .Llabel42
.Llabel42: b .Llabel43
.Llabel43: b .Llabel44
.Llabel44: b .Llabel45
.Llabel45: b .Llabel46
.Llabel46: b .Llabel47
.Llabel47: b .Llabel48
.Llabel48: b .Llabel49
.Llabel49: b .Llabel50
.Llabel50: b .Llabel51
.Llabel51: b .Llabel52
.Llabel52: b .Llabel53
.Llabel53: b .Llabel54
.Llabel54: b .Llabel55
.Llabel55: b .Llabel56
.Llabel56: b .Llabel57
.Llabel57: b .Llabel58
.Llabel58: b .Llabel59
.Llabel59: b .Llabel60
.Llabel60: b .Llabel61
.Llabel61: b .Llabel62
.Llabel62: b .Llabel63
.Llabel63: b .Llabel64
.Llabel64: b .Llabel65
.Llabel65: b .Llabel66
.Llabel66: b .Llabel67
.Llabel67: b .Llabel68
.Llabel68: b .Llabel69
.Llabel69: b .Llabel70
.Llabel70: b .Llabel71
.Llabel71: b .Llabel72
.Llabel72: b .Llabel73
.Llabel73: b .Llabel74
.Llabel74: b .Llabel75
.Llabel75: b .Llabel76
.Llabel76: b .Llabel77
.Llabel77: b .Llabel78
.Llabel78: b .Llabel79
.Llabel79: b .Llabel80
.Llabel80: b .Llabel81
.Llabel81: b .Llabel82
.Llabel82: b .Llabel83
.Llabel83: b .Llabel84
.Llabel84: b .Llabel85
.Llabel85: b .Llabel86
.Llabel86: b .Llabel87
.Llabel87: b .Llabel88
.Llabel88: b .Llabel89
.Llabel89: b .Llabel90
.Llabel90: b .Llabel91
.Llabel91: b .Llabel92
.Llabel92: b .Llabel93
.Llabel93: b .Llabel94
.Llabel94: b .Llabel95
.Llabel95: b .Llabel96
.Llabel96: b .Llabel97
.Llabel97: b .Llabel98
.Llabel98:
    ret
.size func_set_phr, .-func_set_phr