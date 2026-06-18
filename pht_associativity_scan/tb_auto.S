
    .text
    .align 2

.section .text.startup, "ax"
.global _start
.type _start, %function
_start:
    // RNG seed
    mov     w20, #0x1234
    movk    w20, #0xBEEF, lsl #16

    // N = 100000
    mov     w19, #0x86a0
    movk    w19, #0x1, lsl #16

1:  // xorshift32
    eor     w20, w20, w20, lsl #13
    eor     w20, w20, w20, lsr #17
    eor     w20, w20, w20, lsl #5

    // k = x & 1
    and     w0, w20, #1

    //  8 probe branches

    ldr     x16, =branch1
    blr     x16
    ldr     x16, =branch2
    blr     x16
    ldr     x16, =branch3
    blr     x16
    ldr     x16, =branch4
    blr     x16
    ldr     x16, =branch5
    blr     x16
    ldr     x16, =branch6
    blr     x16
    ldr     x16, =branch7
    blr     x16
    ldr     x16, =branch8
    blr     x16

    subs    w19, w19, #1
    b.ne    1b

    mov     x0, #0
    mov     x8, #93
    svc     #0
.size _start, .-_start
.ltorg


// ============================================================
// Branch generator macro
.macro MAKE_BRANCH name, pad_nops
    .section .\name, "ax"
    .global \name
    .type \name, %function
\name:
    stp     x29, x30, [sp, -16]!
    mov     x29, sp

    ldr     x16, =func_set_phr
\name\()_setFunction:
    blr     x16

\name\()_after_set:
    .rept   \pad_nops
    nop
    .endr

\name\()_probe:
    cmp     w0, #0
    b.eq    \name\()_taken

\name\()_fall:
    ldp     x29, x30, [sp], 16
    ret

\name\()_taken:
    ldp     x29, x30, [sp], 16
    ret

    .size \name, .-\name
.endm

// Probe PCs differ by +4 each.
MAKE_BRANCH branch1, 0
MAKE_BRANCH branch2, 1
MAKE_BRANCH branch3, 2
MAKE_BRANCH branch4, 3
MAKE_BRANCH branch5, 4
MAKE_BRANCH branch6, 5
MAKE_BRANCH branch7, 6
MAKE_BRANCH branch8, 7

.ltorg


.section .phr, "ax"
.global func_set_phr
.type func_set_phr, %function
func_set_phr:

    .p2align 6
    b       .Llabel1
    .p2align 6
.Llabel1:
    b       .Llabel2
    .p2align 6
.Llabel2:
    b       .Llabel3
    .p2align 6
.Llabel3:
    b       .Llabel4
    .p2align 6
.Llabel4:
    b       .Llabel5
    .p2align 6
.Llabel5:
    b       .Llabel6
    .p2align 6
.Llabel6:
    b       .Llabel7
    .p2align 6
.Llabel7:
    b       .Llabel8
    .p2align 6
.Llabel8:
    b       .Llabel9
    .p2align 6
.Llabel9:
    b       .Llabel10
    .p2align 6
.Llabel10:
    b       .Llabel11
    .p2align 6
.Llabel11:
    b       .Llabel12
    .p2align 6
.Llabel12:
    b       .Llabel13
    .p2align 6
.Llabel13:
    b       .Llabel14
    .p2align 6
.Llabel14:
    b       .Llabel15
    .p2align 6
.Llabel15:
    b       .Llabel16
    .p2align 6
.Llabel16:
    b       .Llabel17
    .p2align 6
.Llabel17:
    b       .Llabel18
    .p2align 6
.Llabel18:
    b       .Llabel19
    .p2align 6
.Llabel19:
    b       .Llabel20
    .p2align 6
.Llabel20:
    b       .Llabel21
    .p2align 6
.Llabel21:
    b       .Llabel22
    .p2align 6
.Llabel22:
    b       .Llabel23
    .p2align 6
.Llabel23:
    b       .Llabel24
    .p2align 6
.Llabel24:
    b       .Llabel25
    .p2align 6
.Llabel25:
    b       .Llabel26
    .p2align 6
.Llabel26:
    b       .Llabel27
    .p2align 6
.Llabel27:
    b       .Llabel28
    .p2align 6
.Llabel28:
    b       .Llabel29
    .p2align 6
.Llabel29:
    b       .Llabel30
    .p2align 6
.Llabel30:
    b       .Llabel31
    .p2align 6
.Llabel31:
    b       .Llabel32
    .p2align 6
.Llabel32:
    b       .Llabel33
    .p2align 6
.Llabel33:
    b       .Llabel34
    .p2align 6
.Llabel34:
    b       .Llabel35
    .p2align 6
.Llabel35:
    b       .Llabel36
    .p2align 6
.Llabel36:
    b       .Llabel37
    .p2align 6
.Llabel37:
    b       .Llabel38
    .p2align 6
.Llabel38:
    b       .Llabel39
    .p2align 6
.Llabel39:
    b       .Llabel40
    .p2align 6
.Llabel40:
    b       .Llabel41
    .p2align 6
.Llabel41:
    b       .Llabel42
    .p2align 6
.Llabel42:
    b       .Llabel43
    .p2align 6
.Llabel43:
    b       .Llabel44
    .p2align 6
.Llabel44:
    b       .Llabel45
    .p2align 6
.Llabel45:
    b       .Llabel46
    .p2align 6
.Llabel46:
    b       .Llabel47
    .p2align 6
.Llabel47:
    b       .Llabel48
    .p2align 6
.Llabel48:
    b       .Llabel49
    .p2align 6
.Llabel49:
    b       .Llabel50
    .p2align 6
.Llabel50:
    b       .Llabel51
    .p2align 6
.Llabel51:
    b       .Llabel52
    .p2align 6
.Llabel52:
    b       .Llabel53
    .p2align 6
.Llabel53:
    b       .Llabel54
    .p2align 6
.Llabel54:
    b       .Llabel55
    .p2align 6
.Llabel55:
    b       .Llabel56
    .p2align 6
.Llabel56:
    b       .Llabel57
    .p2align 6
.Llabel57:
    b       .Llabel58
    .p2align 6
.Llabel58:
    b       .Llabel59
    .p2align 6
.Llabel59:
    b       .Llabel60
    .p2align 6
.Llabel60:
    b       .Llabel61
    .p2align 6
.Llabel61:
    b       .Llabel62
    .p2align 6
.Llabel62:
    b       .Llabel63
    .p2align 6
.Llabel63:
    b       .Llabel64
    .p2align 6
.Llabel64:
    b       .Llabel65
    .p2align 6
.Llabel65:
    b       .Llabel66
    .p2align 6
.Llabel66:
    b       .Llabel67
    .p2align 6
.Llabel67:
    b       .Llabel68
    .p2align 6
.Llabel68:
    b       .Llabel69
    .p2align 6
.Llabel69:
    b       .Llabel70
    .p2align 6
.Llabel70:
    b       .Llabel71
    .p2align 6
.Llabel71:
    b       .Llabel72
    .p2align 6
.Llabel72:
    b       .Llabel73
    .p2align 6
.Llabel73:
    b       .Llabel74
    .p2align 6
.Llabel74:
    b       .Llabel75
    .p2align 6
.Llabel75:
    b       .Llabel76
    .p2align 6
.Llabel76:
    b       .Llabel77
    .p2align 6
.Llabel77:
    b       .Llabel78
    .p2align 6
.Llabel78:
    b       .Llabel79
    .p2align 6
.Llabel79:
    b       .Llabel80
    .p2align 6
.Llabel80:
    b       .Llabel81
    .p2align 6
.Llabel81:
    b       .Llabel82
    .p2align 6
.Llabel82:
    b       .Llabel83
    .p2align 6
.Llabel83:
    b       .Llabel84
    .p2align 6
.Llabel84:
    b       .Llabel85
    .p2align 6
.Llabel85:
    b       .Llabel86
    .p2align 6
.Llabel86:
    b       .Llabel87
    .p2align 6
.Llabel87:
    b       .Llabel88
    .p2align 6
.Llabel88:
    b       .Llabel89
    .p2align 6
.Llabel89:
    b       .Llabel90
    .p2align 6
.Llabel90:
    b       .Llabel91
    .p2align 6
.Llabel91:
    b       .Llabel92
    .p2align 6
.Llabel92:
    b       .Llabel93
    .p2align 6
.Llabel93:
    b       .Llabel94
    .p2align 6
.Llabel94:
    b       .Llabel95
    .p2align 6
.Llabel95:
    b       .Llabel96
    .p2align 6
.Llabel96:
    b       .Llabel97
    .p2align 6
.Llabel97:
    b       .Llabel98
.Llabel98:
    cmp     w0, #0

    .p2align 6
    b.eq    .L0_inject

    .p2align 6
    b.ne    .L1_inject

    .p2align 6
.L0_inject:
    nop
.L1_inject:
    nop

    .p2align 6
.Llabel99:

    ret
.size func_set_phr, .-func_set_phr