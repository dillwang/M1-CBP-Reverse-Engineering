.text
.global run_pht_align
.type run_pht_align, %function

.equ MAX_D,   110 
.equ CLEAR_N, 100    
.equ SHIFT_N, 97

.macro RAND_BIT
    eor     w10, w10, w10, lsl #13
    eor     w10, w10, w10, lsr #17
    eor     w10, w10, w10, lsl #5
    and     w11, w10, #1
.endm

.macro INJECT_K
    cbnz    w11, 1f
    b       2f
1:
    b       2f
2:
.endm

.macro DUMMY_CHAIN_EXEC wN, CONT_LABEL
    cbz     \wN, \CONT_LABEL

    adr     x16, \CONT_LABEL

    adrp    x1, dummy_addr_table
    add     x1, x1, :lo12:dummy_addr_table

    mov     w4, #MAX_D
    sub     w4, w4, \wN
    uxtw    x2, w4
    lsl     x2, x2, #3
    add     x1, x1, x2

    ldr     x3, [x1]
    br      x3
\CONT_LABEL:
.endm

run_pht_align:
    stp     x29, x30, [sp, -16]!
    mov     x29, sp
    stp     x19, x20, [sp, -16]!
    stp     x21, x22, [sp, -16]!

    mov     x19, x0
    mov     w10, w1

.L_loop:
    cbz     x19, .L_done

    RAND_BIT

    mov     w0, #CLEAR_N
    DUMMY_CHAIN_EXEC w0, .L_after_clear1
.L_after_clear1:
    INJECT_K
    mov     w0, #SHIFT_N
    DUMMY_CHAIN_EXEC w0, .L_after_shift1
.L_after_shift1:

    mov     w14, w11
    b       TB1_ENTRY
TB1_RETURN:

    mov     w0, #CLEAR_N
    DUMMY_CHAIN_EXEC w0, .L_after_clear2
.L_after_clear2:
    INJECT_K
    mov     w0, #SHIFT_N
    DUMMY_CHAIN_EXEC w0, .L_after_shift2
.L_after_shift2:

    eor     w14, w11, #1
    b       TB2_ENTRY
TB2_RETURN:

    adrp    x20, global_sink
    add     x20, x20, :lo12:global_sink
    ldr     x21, [x20]
    add     x21, x21, #1
    str     x21, [x20]

    subs    x19, x19, #1
    b.ne    .L_loop

.L_done:
    ldp     x21, x22, [sp], 16
    ldp     x19, x20, [sp], 16
    ldp     x29, x30, [sp], 16
    ret


.section .tb1, "ax", %progbits
.p2align 2
.global TB1_ENTRY
TB1_ENTRY:
    cbnz    w14, 1f
    b       2f
1:
    b       2f
2:
    b       TB1_RETURN

.section .tb2, "ax", %progbits
.p2align 2
.global TB2_ENTRY
TB2_ENTRY:
    cbnz    w14, 1f
    b       2f
1:
    b       2f
2:
    b       TB2_RETURN



.section .rodata
.align 3
dummy_addr_table:
    .xword D0
    .xword D1
    .xword D2
    .xword D3
    .xword D4
    .xword D5
    .xword D6
    .xword D7
    .xword D8
    .xword D9
    .xword D10
    .xword D11
    .xword D12
    .xword D13
    .xword D14
    .xword D15
    .xword D16
    .xword D17
    .xword D18
    .xword D19
    .xword D20
    .xword D21
    .xword D22
    .xword D23
    .xword D24
    .xword D25
    .xword D26
    .xword D27
    .xword D28
    .xword D29
    .xword D30
    .xword D31
    .xword D32
    .xword D33
    .xword D34
    .xword D35
    .xword D36
    .xword D37
    .xword D38
    .xword D39
    .xword D40
    .xword D41
    .xword D42
    .xword D43
    .xword D44
    .xword D45
    .xword D46
    .xword D47
    .xword D48
    .xword D49
    .xword D50
    .xword D51
    .xword D52
    .xword D53
    .xword D54
    .xword D55
    .xword D56
    .xword D57
    .xword D58
    .xword D59
    .xword D60
    .xword D61
    .xword D62
    .xword D63
    .xword D64
    .xword D65
    .xword D66
    .xword D67
    .xword D68
    .xword D69
    .xword D70
    .xword D71
    .xword D72
    .xword D73
    .xword D74
    .xword D75
    .xword D76
    .xword D77
    .xword D78
    .xword D79
    .xword D80
    .xword D81
    .xword D82
    .xword D83
    .xword D84
    .xword D85
    .xword D86
    .xword D87
    .xword D88
    .xword D89
    .xword D90
    .xword D91
    .xword D92
    .xword D93
    .xword D94
    .xword D95
    .xword D96
    .xword D97
    .xword D98
    .xword D99
    .xword D100
    .xword D101
    .xword D102
    .xword D103
    .xword D104
    .xword D105
    .xword D106
    .xword D107
    .xword D108
    .xword D109
    .xword D110

.text
D0:    b D1
D1:    b D2
D2:    b D3
D3:    b D4
D4:    b D5
D5:    b D6
D6:    b D7
D7:    b D8
D8:    b D9
D9:    b D10
D10:   b D11
D11:   b D12
D12:   b D13
D13:   b D14
D14:   b D15
D15:   b D16
D16:   b D17
D17:   b D18
D18:   b D19
D19:   b D20
D20:   b D21
D21:   b D22
D22:   b D23
D23:   b D24
D24:   b D25
D25:   b D26
D26:   b D27
D27:   b D28
D28:   b D29
D29:   b D30
D30:   b D31
D31:   b D32
D32:   b D33
D33:   b D34
D34:   b D35
D35:   b D36
D36:   b D37
D37:   b D38
D38:   b D39
D39:   b D40
D40:   b D41
D41:   b D42
D42:   b D43
D43:   b D44
D44:   b D45
D45:   b D46
D46:   b D47
D47:   b D48
D48:   b D49
D49:   b D50
D50:   b D51
D51:   b D52
D52:   b D53
D53:   b D54
D54:   b D55
D55:   b D56
D56:   b D57
D57:   b D58
D58:   b D59
D59:   b D60
D60:   b D61
D61:   b D62
D62:   b D63
D63:   b D64
D64:   b D65
D65:   b D66
D66:   b D67
D67:   b D68
D68:   b D69
D69:   b D70
D70:   b D71
D71:   b D72
D72:   b D73
D73:   b D74
D74:   b D75
D75:   b D76
D76:   b D77
D77:   b D78
D78:   b D79
D79:   b D80
D80:   b D81
D81:   b D82
D82:   b D83
D83:   b D84
D84:   b D85
D85:   b D86
D86:   b D87
D87:   b D88
D88:   b D89
D89:   b D90
D90:   b D91
D91:   b D92
D92:   b D93
D93:   b D94
D94:   b D95
D95:   b D96
D96:   b D97
D97:   b D98
D98:   b D99
D99:   b D100
D100:  b D101
D101:  b D102
D102:  b D103
D103:  b D104
D104:  b D105
D105:  b D106
D106:  b D107
D107:  b D108
D108:  b D109
D109:  b D110
D110:  b DUMMY_EXIT

DUMMY_EXIT:
    br x16
