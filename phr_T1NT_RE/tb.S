.text
.global main
.type main, %function

main:
    stp x29, x30, [sp, -16]!
    mov x29, sp
    stp x19, x20, [sp, -16]!
    stp x21, x22, [sp, -16]!

    // tries = 1,000,000
    movz x19, #0x4240
    movk x19, #0xF, lsl #16

    mov w21, #1          // xorshift state

    // warmup
    mov x20, #0
    bl  dummy_chain

    // measurement
    mov x20, #1

loop_top:
    cbz x19, loop_done

    // k = xorshift32() & 1
    mov  w22, w21
    eor  w22, w22, w22, lsl #13
    eor  w22, w22, w22, lsr #17
    eor  w22, w22, w22, lsl #5
    mov  w21, w22
    and  w22, w22, #1

    // Train
    cbnz w22, L_train
L_train:
    nop

    // Same dummy function every time
    bl  dummy_chain

    // Probe
    cbnz w22, L_probe
L_probe:
    nop

    subs x19, x19, #1
    b.ne loop_top

loop_done:
    mov w0, #0
    ldp x21, x22, [sp], 16
    ldp x19, x20, [sp], 16
    ldp x29, x30, [sp], 16
    ret

// dummy_chain
// x20 = 0 all taken
// x20 = 1 all not taken
dummy_chain:
    cbz x20, L1
L1:
    cbz x20, L2
L2:
    cbz x20, L3
L3:
    cbz x20, L4
L4:
    cbz x20, L5
L5:
    cbz x20, L6
L6:
    cbz x20, L7
L7:
    cbz x20, L8
L8:
    cbz x20, L9
L9:
    cbz x20, L10
L10:
    cbz x20, L11
L11:
    cbz x20, L12
L12:
    cbz x20, L13
L13:
    cbz x20, L14
L14:
    cbz x20, L15
L15:
    cbz x20, L16
L16:
    cbz x20, L17
L17:
    cbz x20, L18
L18:
    cbz x20, L19
L19:
    cbz x20, L20
L20:
    cbz x20, L21
L21:
    cbz x20, L22
L22:
    cbz x20, L23
L23:
    cbz x20, L24
L24:
    cbz x20, L25
L25:
    cbz x20, L26
L26:
    cbz x20, L27
L27:
    cbz x20, L28
L28:
    cbz x20, L29
L29:
    cbz x20, L30
L30:
    cbz x20, L31
L31:
    cbz x20, L32
L32:
    cbz x20, L33
L33:
    cbz x20, L34
L34:
    cbz x20, L35
L35:
    cbz x20, L36
L36:
    cbz x20, L37
L37:
    cbz x20, L38
L38:
    cbz x20, L39
L39:
    cbz x20, L40
L40:
    cbz x20, L41
L41:
    cbz x20, L42
L42:
    cbz x20, L43
L43:
    cbz x20, L44
L44:
    cbz x20, L45
L45:
    cbz x20, L46
L46:
    cbz x20, L47
L47:
    cbz x20, L48
L48:
    cbz x20, L49
L49:
    cbz x20, L50
L50:
    cbz x20, L51
L51:
    cbz x20, L52
L52:
    cbz x20, L53
L53:
    cbz x20, L54
L54:
    cbz x20, L55
L55:
    cbz x20, L56
L56:
    cbz x20, L57
L57:
    cbz x20, L58
L58:
    cbz x20, L59
L59:
    cbz x20, L60
L60:
    cbz x20, L61
L61:
    cbz x20, L62
L62:
    cbz x20, L63
L63:
    cbz x20, L64
L64:
    cbz x20, L65
L65:
    cbz x20, L66
L66:
    cbz x20, L67
L67:
    cbz x20, L68
L68:
    cbz x20, L69
L69:
    cbz x20, L70
L70:
    cbz x20, L71
L71:
    cbz x20, L72
L72:
    cbz x20, L73
L73:
    cbz x20, L74
L74:
    cbz x20, L75
L75:
    cbz x20, L76
L76:
    cbz x20, L77
L77:
    cbz x20, L78
L78:
    cbz x20, L79
L79:
    cbz x20, L80
L80:
    cbz x20, L81
L81:
    cbz x20, L82
L82:
    cbz x20, L83
L83:
    cbz x20, L84
L84:
    cbz x20, L85
L85:
    cbz x20, L86
L86:
    cbz x20, L87
L87:
    cbz x20, L88
L88:
    cbz x20, L89
L89:
    cbz x20, L90
L90:
    cbz x20, L91
L91:
    cbz x20, L92
L92:
    cbz x20, L93
L93:
    cbz x20, L94
L94:
    cbz x20, L95
L95:
    cbz x20, L96
L96:
    cbz x20, L97
L97:
    cbz x20, L98
L98:
    ret