// func_set_phr(k):
    .text
    .align  2

    .global func_set_phr
    .type   func_set_phr, %function
func_set_phr:
    // Set flags from k
    cmp     w0, #0

    b.ne    .L0_inject
    b.eq    .L1_inject

    b       .L0

.L0_inject:
    b       .L0
.L1_inject:
    b       .L0

.L0:
    b       .L1
.L1: b     .L2
.L2: b     .L3 
.L3: b     .L4
.L4: b     .L5
.L5: b     .L6
.L6: b     .L7
.L7: b     .L8
.L8: b     .L9
.L9: b     .L10
.L10: b    .L11
.L11: b    .L12
.L12: b    .L13
.L13: b    .L14
.L14: b    .L15
.L15: b    .L16
.L16: b    .L17
.L17: b    .L18
.L18: b    .L19
.L19: b    .L20
.L20: b    .L21
.L21: b    .L22
.L22: b    .L23
.L23: b    .L24
.L24: b    .L25
.L25: b    .L26
.L26: b    .L27
.L27: b    .L28
.L28: b    .L29
.L29: b    .L30
.L30: b    .L31
.L31: b    .L32
.L32: b    .L33
.L33: b    .L34
.L34: b    .L35
.L35: b    .L36
.L36: b    .L37
.L37: b    .L38
.L38: b    .L39
.L39: b    .L40
.L40: b    .L41
.L41: b    .L42
.L42: b    .L43
.L43: b    .L44
.L44: b    .L45
.L45: b    .L46
.L46: b    .L47
.L47: b    .L48
.L48: b    .L49
.L49: b    .L50
.L50: b    .L51
.L51: b    .L52
.L52: b    .L53
.L53: b    .L54
.L54: b    .L55
.L55: b    .L56
.L56: b    .L57
.L57: b    .L58
.L58: b    .L59
.L59: b    .L60
.L60: b    .L61
.L61: b    .L62
.L62: b    .L63
.L63: b    .L64
.L64: b    .L65
.L65: b    .L66
.L66: b    .L67
.L67: b    .L68
.L68: b    .L69
.L69: b    .L70
.L70: b    .L71
.L71: b    .L72
.L72: b    .L73
.L73: b    .L74
.L74: b    .L75
.L75: b    .L76
.L76: b    .L77
.L77: b    .L78
.L78: b    .L79
.L79: b    .L80
.L80: b    .L81
.L81: b    .L82
.L82: b    .L83
.L83: b    .L84
.L84: b    .L85
.L85: b    .L86
.L86: b    .L87
.L87: b    .L88
.L88: b    .L89
.L89: b    .L90
.L90: b    .L91
.L91: b    .L92
.L92: b    .L93
.L93: b    .L94
.L94: b    .L95
.L95: b    .L96
.L96: b    .L97
.L97:
    ret

    .size   func_set_phr, .-func_set_phr
