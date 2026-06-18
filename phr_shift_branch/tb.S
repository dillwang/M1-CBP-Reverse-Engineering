// tb.S — AArch64 GAS, Firestorm differential PHR footprint test (toggle bits 2..10)
//
// ABI:
//   x0 = iters
//   w1 = seed
//   w2 = ndummy
//
    .text
    .arch armv8-a
    .align 2

    .equ MAX_DUMMY, 160

// xorshift32: w10 state -> w11 = k (0/1)
    .macro XORSHIFT32
    eor     w10, w10, w10, lsl #13
    eor     w10, w10, w10, lsr #17
    eor     w10, w10, w10, lsl #5
    and     w11, w10, #1
    .endm

// Load address of dummy table into x20
    .macro LOAD_TABLE_BASE
    adrp    x20, dummy_addr_table
    add     x20, x20, :lo12:dummy_addr_table
    .endm

// Generate one function for a given toggle bit.
// Params:
//   NAME: function name
//   BIT : toggle bit (2..10)
//
// Derived:
//   BASE_ALIGN = BIT+1  (so site A has bits[BIT:0]=0)
//   PAD_NOPS   = 2^(BIT-2) - 1  (so site B is exactly 2^BIT bytes after site A)
//
    .macro GEN_FUNC NAME, BIT, BASE_ALIGN, PAD_NOPS
    .global \NAME
    .type   \NAME, %function
\NAME:
    mov     x9, x0          // iters
    mov     w10, w1         // seed
    mov     w12, w2         // ndummy

    LOAD_TABLE_BASE

.L_loop_\NAME:
    XORSHIFT32
    tst     w11, w11        // flags from k

    // Injection pair
    .p2align \BASE_ALIGN
.L_inj_cond_\NAME:
    b.ne    .L_l0_\NAME     // taken when k=1

    .rept \PAD_NOPS
    nop
    .endr

.L_inj_uncond_\NAME:
    b       .L_l0_\NAME     // taken when k=0

.L_l0_\NAME:
    // x24 = return label after dummy chain
    adrp    x24, .L_after_dummies_\NAME
    add     x24, x24, :lo12:.L_after_dummies_\NAME

    // index = MAX_DUMMY - ndummy
    uxtw    x21, w12
    mov     x23, #MAX_DUMMY
    sub     x21, x23, x21

    // x22 = dummy_addr_table[index]
    lsl     x21, x21, #3
    add     x22, x20, x21
    ldr     x22, [x22]

    // enter dummy chain
    br      x22

.L_after_dummies_\NAME:
    // --- Probe (same flags) ---
    b.ne    .L_probe_tgt_\NAME
    nop
.L_probe_tgt_\NAME:

    subs    x9, x9, #1
    b.ne    .L_loop_\NAME
    ret
    .size \NAME, .-\NAME
    .endm

// -------------------- Dummy chain table --------------------
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
    .xword D111
    .xword D112
    .xword D113
    .xword D114
    .xword D115
    .xword D116
    .xword D117
    .xword D118
    .xword D119
    .xword D120
    .xword D121
    .xword D122
    .xword D123
    .xword D124
    .xword D125
    .xword D126
    .xword D127
    .xword D128
    .xword D129
    .xword D130
    .xword D131
    .xword D132
    .xword D133
    .xword D134
    .xword D135
    .xword D136
    .xword D137
    .xword D138
    .xword D139
    .xword D140
    .xword D141
    .xword D142
    .xword D143
    .xword D144
    .xword D145
    .xword D146
    .xword D147
    .xword D148
    .xword D149
    .xword D150
    .xword D151
    .xword D152
    .xword D153
    .xword D154
    .xword D155
    .xword D156
    .xword D157
    .xword D158
    .xword D159
    .xword D160

    .text
D0:   b D1
D1:   b D2
D2:   b D3
D3:   b D4
D4:   b D5
D5:   b D6
D6:   b D7
D7:   b D8
D8:   b D9
D9:   b D10
D10:  b D11
D11:  b D12
D12:  b D13
D13:  b D14
D14:  b D15
D15:  b D16
D16:  b D17
D17:  b D18
D18:  b D19
D19:  b D20
D20:  b D21
D21:  b D22
D22:  b D23
D23:  b D24
D24:  b D25
D25:  b D26
D26:  b D27
D27:  b D28
D28:  b D29
D29:  b D30
D30:  b D31
D31:  b D32
D32:  b D33
D33:  b D34
D34:  b D35
D35:  b D36
D36:  b D37
D37:  b D38
D38:  b D39
D39:  b D40
D40:  b D41
D41:  b D42
D42:  b D43
D43:  b D44
D44:  b D45
D45:  b D46
D46:  b D47
D47:  b D48
D48:  b D49
D49:  b D50
D50:  b D51
D51:  b D52
D52:  b D53
D53:  b D54
D54:  b D55
D55:  b D56
D56:  b D57
D57:  b D58
D58:  b D59
D59:  b D60
D60:  b D61
D61:  b D62
D62:  b D63
D63:  b D64
D64:  b D65
D65:  b D66
D66:  b D67
D67:  b D68
D68:  b D69
D69:  b D70
D70:  b D71
D71:  b D72
D72:  b D73
D73:  b D74
D74:  b D75
D75:  b D76
D76:  b D77
D77:  b D78
D78:  b D79
D79:  b D80
D80:  b D81
D81:  b D82
D82:  b D83
D83:  b D84
D84:  b D85
D85:  b D86
D86:  b D87
D87:  b D88
D88:  b D89
D89:  b D90
D90:  b D91
D91:  b D92
D92:  b D93
D93:  b D94
D94:  b D95
D95:  b D96
D96:  b D97
D97:  b D98
D98:  b D99
D99:  b D100
D100: b D101
D101: b D102
D102: b D103
D103: b D104
D104: b D105
D105: b D106
D106: b D107
D107: b D108
D108: b D109
D109: b D110
D110: b D111
D111: b D112
D112: b D113
D113: b D114
D114: b D115
D115: b D116
D116: b D117
D117: b D118
D118: b D119
D119: b D120
D120: b D121
D121: b D122
D122: b D123
D123: b D124
D124: b D125
D125: b D126
D126: b D127
D127: b D128
D128: b D129
D129: b D130
D130: b D131
D131: b D132
D132: b D133
D133: b D134
D134: b D135
D135: b D136
D136: b D137
D137: b D138
D138: b D139
D139: b D140
D140: b D141
D141: b D142
D142: b D143
D143: b D144
D144: b D145
D145: b D146
D146: b D147
D147: b D148
D148: b D149
D149: b D150
D150: b D151
D151: b D152
D152: b D153
D153: b D154
D154: b D155
D155: b D156
D156: b D157
D157: b D158
D158: b D159
D159: b D160
D160: br x24

// -------------------- Instantiate bits 2..10 --------------------
//
// PAD_NOPS = 2^(BIT-2) - 1
// BASE_ALIGN = BIT+1
//
// bit2:  PAD=0,   align=3
// bit3:  PAD=1,   align=4
// bit4:  PAD=3,   align=5
// bit5:  PAD=7,   align=6
// bit6:  PAD=15,  align=7
// bit7:  PAD=31,  align=8
// bit8:  PAD=63,  align=9
// bit9:  PAD=127, align=10
// bit10: PAD=255, align=11
    GEN_FUNC run_inject_bit2,  2,  3,   0
    GEN_FUNC run_inject_bit3,  3,  4,   1
    GEN_FUNC run_inject_bit4,  4,  5,   3
    GEN_FUNC run_inject_bit5,  5,  6,   7
    GEN_FUNC run_inject_bit6,  6,  7,  15
    GEN_FUNC run_inject_bit7,  7,  8,  31
    GEN_FUNC run_inject_bit8,  8,  9,  63
    GEN_FUNC run_inject_bit9,  9, 10, 127
    GEN_FUNC run_inject_bit10, 10, 11, 255
    GEN_FUNC run_inject_bit11,11, 12, 511
    GEN_FUNC run_inject_bit12,12, 13, 1023
    GEN_FUNC run_inject_bit13,13, 14, 2047
    GEN_FUNC run_inject_bit14,14, 15, 4095
    GEN_FUNC run_inject_bit15,15, 16, 8191
    GEN_FUNC run_inject_bit16,16, 17, 16383
    GEN_FUNC run_inject_bit17,17, 18, 32767
    GEN_FUNC run_inject_bit18,18, 18, 65535






