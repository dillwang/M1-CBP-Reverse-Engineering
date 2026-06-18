// tb.S — AArch64 loop: fixed-PC indirect call to L0/L1 (far placed by linker),
// then dummy branch chain, then conditional probe.
//
// ABI: x0=iters, w1=seed, w2=ndummy
//
// External symbols:
//   L0, L1  (in targets.S, placed by linker script)
//   global_sink (in tb.c)

    .text
    .arch armv8-a
    .align 2
    .equ MAX_DUMMY, 160

    .extern L0
    .extern L1
    .extern global_sink

    .macro XORSHIFT32
    eor     w10, w10, w10, lsl #13
    eor     w10, w10, w10, lsr #17
    eor     w10, w10, w10, lsl #5
    and     w11, w10, #1          // k in w11 (0/1)
    .endm

    .macro LOAD_TABLE_BASE
    adrp    x20, dummy_addr_table
    add     x20, x20, :lo12:dummy_addr_table
    .endm

    .global run_target_ld
    .type   run_target_ld, %function
run_target_ld:
    // ---- prologue: save regs we use + make a stable loop counter ----
    stp     x29, x30, [sp, -16]!
    mov     x29, sp
    stp     x19, x20, [sp, -16]!
    stp     x21, x22, [sp, -16]!
    stp     x23, x24, [sp, -16]!
    stp     x26, x27, [sp, -16]!
    str     x28, [sp, -16]!

    mov     x28, x0              // loop counter lives in x28 (callee-saved)

    mov     w10, w1              // seed
    mov     w12, w2              // ndummy


    // Resolve L0/L1 addresses once (PIC-safe)
    adrp    x26, L0
    add     x26, x26, :lo12:L0
    adrp    x27, L1
    add     x27, x27, :lo12:L1

    LOAD_TABLE_BASE

.L_loop:
    XORSHIFT32

    // Choose target based on k
    tst     w11, w11
    csel    x15, x27, x26, ne

    // Fixed-PC indirect call; L0/L1 just "ret"
    blr     x15

    // Return label for dummy chain
    adr     x24, .L_after_dummies

    // Clamp ndummy to [0, MAX_DUMMY] in case caller passes something weird
    mov     w13, #MAX_DUMMY
    cmp     w12, w13
    csel    w12, w12, w13, ls

    // index = MAX_DUMMY - ndummy
    uxtw    x21, w12
    mov     x23, #MAX_DUMMY
    sub     x21, x23, x21
    lsl     x21, x21, #3
    add     x22, x20, x21
    ldr     x22, [x22]
    br      x22

.L_after_dummies:
    // Probe conditional branch depends on k (recreate flags here!)
    tst     w11, w11
    b.ne    .L_probe_taken
    nop
    b       .L_probe_join
.L_probe_taken:
    nop
.L_probe_join:
    // Touch a volatile to keep the compiler honest across files
    adrp    x19, global_sink
    add     x19, x19, :lo12:global_sink
    ldr     x18, [x19]
    add     x18, x18, #1
    str     x18, [x19]

    subs    x28, x28, #1
    b.ne    .L_loop

    //epilogue
    ldr     x28, [sp], 16
    ldp     x26, x27, [sp], 16
    ldp     x23, x24, [sp], 16
    ldp     x21, x22, [sp], 16
    ldp     x19, x20, [sp], 16
    ldp     x29, x30, [sp], 16
    ret

    .size run_target_ld, .-run_target_ld

// ---------------- Dummy chain table + chain ----------------
    .section .rodata
    .align 3
dummy_addr_table:
    .xword D0, D1, D2, D3, D4, D5, D6, D7, D8, D9
    .xword D10, D11, D12, D13, D14, D15, D16, D17, D18, D19
    .xword D20, D21, D22, D23, D24, D25, D26, D27, D28, D29
    .xword D30, D31, D32, D33, D34, D35, D36, D37, D38, D39
    .xword D40, D41, D42, D43, D44, D45, D46, D47, D48, D49
    .xword D50, D51, D52, D53, D54, D55, D56, D57, D58, D59
    .xword D60, D61, D62, D63, D64, D65, D66, D67, D68, D69
    .xword D70, D71, D72, D73, D74, D75, D76, D77, D78, D79
    .xword D80, D81, D82, D83, D84, D85, D86, D87, D88, D89
    .xword D90, D91, D92, D93, D94, D95, D96, D97, D98, D99
    .xword D100, D101, D102, D103, D104, D105, D106, D107, D108, D109
    .xword D110, D111, D112, D113, D114, D115, D116, D117, D118, D119
    .xword D120, D121, D122, D123, D124, D125, D126, D127, D128, D129
    .xword D130, D131, D132, D133, D134, D135, D136, D137, D138, D139
    .xword D140, D141, D142, D143, D144, D145, D146, D147, D148, D149
    .xword D150, D151, D152, D153, D154, D155, D156, D157, D158, D159
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
