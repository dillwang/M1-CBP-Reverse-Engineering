// auto-generated dummy_chain_a64.S (GAS/AArch64)
.text
.global dummy_chain
.type   dummy_chain, %function
.equ MAX_DUMMY, 256

// void dummy_chain(long n)
// x0 = n (0..MAX_DUMMY)
dummy_chain:
    // clamp n
    cmp x0, #MAX_DUMMY
    b.ls 1f
    mov x0, #MAX_DUMMY
1:
    // jump via table
    adrp x1, dummy_jumptable
    add  x1, x1, :lo12:dummy_jumptable
    ldr  x2, [x1, x0, lsl #3]
    br   x2

.align 3
dummy_jumptable:
    .8byte entry_0
    .8byte entry_1
    .8byte entry_2
    .8byte entry_3
    .8byte entry_4
    .8byte entry_5
    .8byte entry_6
    .8byte entry_7
    .8byte entry_8
    .8byte entry_9
    .8byte entry_10
    .8byte entry_11
    .8byte entry_12
    .8byte entry_13
    .8byte entry_14
    .8byte entry_15
    .8byte entry_16
    .8byte entry_17
    .8byte entry_18
    .8byte entry_19
    .8byte entry_20
    .8byte entry_21
    .8byte entry_22
    .8byte entry_23
    .8byte entry_24
    .8byte entry_25
    .8byte entry_26
    .8byte entry_27
    .8byte entry_28
    .8byte entry_29
    .8byte entry_30
    .8byte entry_31
    .8byte entry_32
    .8byte entry_33
    .8byte entry_34
    .8byte entry_35
    .8byte entry_36
    .8byte entry_37
    .8byte entry_38
    .8byte entry_39
    .8byte entry_40
    .8byte entry_41
    .8byte entry_42
    .8byte entry_43
    .8byte entry_44
    .8byte entry_45
    .8byte entry_46
    .8byte entry_47
    .8byte entry_48
    .8byte entry_49
    .8byte entry_50
    .8byte entry_51
    .8byte entry_52
    .8byte entry_53
    .8byte entry_54
    .8byte entry_55
    .8byte entry_56
    .8byte entry_57
    .8byte entry_58
    .8byte entry_59
    .8byte entry_60
    .8byte entry_61
    .8byte entry_62
    .8byte entry_63
    .8byte entry_64
    .8byte entry_65
    .8byte entry_66
    .8byte entry_67
    .8byte entry_68
    .8byte entry_69
    .8byte entry_70
    .8byte entry_71
    .8byte entry_72
    .8byte entry_73
    .8byte entry_74
    .8byte entry_75
    .8byte entry_76
    .8byte entry_77
    .8byte entry_78
    .8byte entry_79
    .8byte entry_80
    .8byte entry_81
    .8byte entry_82
    .8byte entry_83
    .8byte entry_84
    .8byte entry_85
    .8byte entry_86
    .8byte entry_87
    .8byte entry_88
    .8byte entry_89
    .8byte entry_90
    .8byte entry_91
    .8byte entry_92
    .8byte entry_93
    .8byte entry_94
    .8byte entry_95
    .8byte entry_96
    .8byte entry_97
    .8byte entry_98
    .8byte entry_99
    .8byte entry_100
    .8byte entry_101
    .8byte entry_102
    .8byte entry_103
    .8byte entry_104
    .8byte entry_105
    .8byte entry_106
    .8byte entry_107
    .8byte entry_108
    .8byte entry_109
    .8byte entry_110
    .8byte entry_111
    .8byte entry_112
    .8byte entry_113
    .8byte entry_114
    .8byte entry_115
    .8byte entry_116
    .8byte entry_117
    .8byte entry_118
    .8byte entry_119
    .8byte entry_120
    .8byte entry_121
    .8byte entry_122
    .8byte entry_123
    .8byte entry_124
    .8byte entry_125
    .8byte entry_126
    .8byte entry_127
    .8byte entry_128
    .8byte entry_129
    .8byte entry_130
    .8byte entry_131
    .8byte entry_132
    .8byte entry_133
    .8byte entry_134
    .8byte entry_135
    .8byte entry_136
    .8byte entry_137
    .8byte entry_138
    .8byte entry_139
    .8byte entry_140
    .8byte entry_141
    .8byte entry_142
    .8byte entry_143
    .8byte entry_144
    .8byte entry_145
    .8byte entry_146
    .8byte entry_147
    .8byte entry_148
    .8byte entry_149
    .8byte entry_150
    .8byte entry_151
    .8byte entry_152
    .8byte entry_153
    .8byte entry_154
    .8byte entry_155
    .8byte entry_156
    .8byte entry_157
    .8byte entry_158
    .8byte entry_159
    .8byte entry_160
    .8byte entry_161
    .8byte entry_162
    .8byte entry_163
    .8byte entry_164
    .8byte entry_165
    .8byte entry_166
    .8byte entry_167
    .8byte entry_168
    .8byte entry_169
    .8byte entry_170
    .8byte entry_171
    .8byte entry_172
    .8byte entry_173
    .8byte entry_174
    .8byte entry_175
    .8byte entry_176
    .8byte entry_177
    .8byte entry_178
    .8byte entry_179
    .8byte entry_180
    .8byte entry_181
    .8byte entry_182
    .8byte entry_183
    .8byte entry_184
    .8byte entry_185
    .8byte entry_186
    .8byte entry_187
    .8byte entry_188
    .8byte entry_189
    .8byte entry_190
    .8byte entry_191
    .8byte entry_192
    .8byte entry_193
    .8byte entry_194
    .8byte entry_195
    .8byte entry_196
    .8byte entry_197
    .8byte entry_198
    .8byte entry_199
    .8byte entry_200
    .8byte entry_201
    .8byte entry_202
    .8byte entry_203
    .8byte entry_204
    .8byte entry_205
    .8byte entry_206
    .8byte entry_207
    .8byte entry_208
    .8byte entry_209
    .8byte entry_210
    .8byte entry_211
    .8byte entry_212
    .8byte entry_213
    .8byte entry_214
    .8byte entry_215
    .8byte entry_216
    .8byte entry_217
    .8byte entry_218
    .8byte entry_219
    .8byte entry_220
    .8byte entry_221
    .8byte entry_222
    .8byte entry_223
    .8byte entry_224
    .8byte entry_225
    .8byte entry_226
    .8byte entry_227
    .8byte entry_228
    .8byte entry_229
    .8byte entry_230
    .8byte entry_231
    .8byte entry_232
    .8byte entry_233
    .8byte entry_234
    .8byte entry_235
    .8byte entry_236
    .8byte entry_237
    .8byte entry_238
    .8byte entry_239
    .8byte entry_240
    .8byte entry_241
    .8byte entry_242
    .8byte entry_243
    .8byte entry_244
    .8byte entry_245
    .8byte entry_246
    .8byte entry_247
    .8byte entry_248
    .8byte entry_249
    .8byte entry_250
    .8byte entry_251
    .8byte entry_252
    .8byte entry_253
    .8byte entry_254
    .8byte entry_255
    .8byte entry_256

.align 4
entry_0:
    ret

.align 4
entry_1:
    .rept 1
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_2:
    .rept 2
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_3:
    .rept 3
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_4:
    .rept 4
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_5:
    .rept 5
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_6:
    .rept 6
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_7:
    .rept 7
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_8:
    .rept 8
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_9:
    .rept 9
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_10:
    .rept 10
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_11:
    .rept 11
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_12:
    .rept 12
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_13:
    .rept 13
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_14:
    .rept 14
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_15:
    .rept 15
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_16:
    .rept 16
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_17:
    .rept 17
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_18:
    .rept 18
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_19:
    .rept 19
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_20:
    .rept 20
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_21:
    .rept 21
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_22:
    .rept 22
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_23:
    .rept 23
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_24:
    .rept 24
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_25:
    .rept 25
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_26:
    .rept 26
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_27:
    .rept 27
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_28:
    .rept 28
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_29:
    .rept 29
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_30:
    .rept 30
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_31:
    .rept 31
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_32:
    .rept 32
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_33:
    .rept 33
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_34:
    .rept 34
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_35:
    .rept 35
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_36:
    .rept 36
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_37:
    .rept 37
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_38:
    .rept 38
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_39:
    .rept 39
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_40:
    .rept 40
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_41:
    .rept 41
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_42:
    .rept 42
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_43:
    .rept 43
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_44:
    .rept 44
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_45:
    .rept 45
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_46:
    .rept 46
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_47:
    .rept 47
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_48:
    .rept 48
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_49:
    .rept 49
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_50:
    .rept 50
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_51:
    .rept 51
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_52:
    .rept 52
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_53:
    .rept 53
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_54:
    .rept 54
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_55:
    .rept 55
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_56:
    .rept 56
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_57:
    .rept 57
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_58:
    .rept 58
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_59:
    .rept 59
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_60:
    .rept 60
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_61:
    .rept 61
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_62:
    .rept 62
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_63:
    .rept 63
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_64:
    .rept 64
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_65:
    .rept 65
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_66:
    .rept 66
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_67:
    .rept 67
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_68:
    .rept 68
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_69:
    .rept 69
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_70:
    .rept 70
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_71:
    .rept 71
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_72:
    .rept 72
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_73:
    .rept 73
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_74:
    .rept 74
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_75:
    .rept 75
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_76:
    .rept 76
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_77:
    .rept 77
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_78:
    .rept 78
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_79:
    .rept 79
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_80:
    .rept 80
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_81:
    .rept 81
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_82:
    .rept 82
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_83:
    .rept 83
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_84:
    .rept 84
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_85:
    .rept 85
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_86:
    .rept 86
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_87:
    .rept 87
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_88:
    .rept 88
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_89:
    .rept 89
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_90:
    .rept 90
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_91:
    .rept 91
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_92:
    .rept 92
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_93:
    .rept 93
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_94:
    .rept 94
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_95:
    .rept 95
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_96:
    .rept 96
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_97:
    .rept 97
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_98:
    .rept 98
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_99:
    .rept 99
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_100:
    .rept 100
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_101:
    .rept 101
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_102:
    .rept 102
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_103:
    .rept 103
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_104:
    .rept 104
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_105:
    .rept 105
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_106:
    .rept 106
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_107:
    .rept 107
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_108:
    .rept 108
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_109:
    .rept 109
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_110:
    .rept 110
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_111:
    .rept 111
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_112:
    .rept 112
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_113:
    .rept 113
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_114:
    .rept 114
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_115:
    .rept 115
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_116:
    .rept 116
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_117:
    .rept 117
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_118:
    .rept 118
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_119:
    .rept 119
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_120:
    .rept 120
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_121:
    .rept 121
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_122:
    .rept 122
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_123:
    .rept 123
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_124:
    .rept 124
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_125:
    .rept 125
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_126:
    .rept 126
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_127:
    .rept 127
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_128:
    .rept 128
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_129:
    .rept 129
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_130:
    .rept 130
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_131:
    .rept 131
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_132:
    .rept 132
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_133:
    .rept 133
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_134:
    .rept 134
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_135:
    .rept 135
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_136:
    .rept 136
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_137:
    .rept 137
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_138:
    .rept 138
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_139:
    .rept 139
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_140:
    .rept 140
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_141:
    .rept 141
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_142:
    .rept 142
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_143:
    .rept 143
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_144:
    .rept 144
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_145:
    .rept 145
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_146:
    .rept 146
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_147:
    .rept 147
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_148:
    .rept 148
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_149:
    .rept 149
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_150:
    .rept 150
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_151:
    .rept 151
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_152:
    .rept 152
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_153:
    .rept 153
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_154:
    .rept 154
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_155:
    .rept 155
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_156:
    .rept 156
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_157:
    .rept 157
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_158:
    .rept 158
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_159:
    .rept 159
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_160:
    .rept 160
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_161:
    .rept 161
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_162:
    .rept 162
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_163:
    .rept 163
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_164:
    .rept 164
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_165:
    .rept 165
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_166:
    .rept 166
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_167:
    .rept 167
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_168:
    .rept 168
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_169:
    .rept 169
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_170:
    .rept 170
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_171:
    .rept 171
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_172:
    .rept 172
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_173:
    .rept 173
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_174:
    .rept 174
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_175:
    .rept 175
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_176:
    .rept 176
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_177:
    .rept 177
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_178:
    .rept 178
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_179:
    .rept 179
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_180:
    .rept 180
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_181:
    .rept 181
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_182:
    .rept 182
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_183:
    .rept 183
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_184:
    .rept 184
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_185:
    .rept 185
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_186:
    .rept 186
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_187:
    .rept 187
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_188:
    .rept 188
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_189:
    .rept 189
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_190:
    .rept 190
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_191:
    .rept 191
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_192:
    .rept 192
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_193:
    .rept 193
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_194:
    .rept 194
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_195:
    .rept 195
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_196:
    .rept 196
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_197:
    .rept 197
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_198:
    .rept 198
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_199:
    .rept 199
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_200:
    .rept 200
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_201:
    .rept 201
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_202:
    .rept 202
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_203:
    .rept 203
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_204:
    .rept 204
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_205:
    .rept 205
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_206:
    .rept 206
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_207:
    .rept 207
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_208:
    .rept 208
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_209:
    .rept 209
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_210:
    .rept 210
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_211:
    .rept 211
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_212:
    .rept 212
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_213:
    .rept 213
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_214:
    .rept 214
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_215:
    .rept 215
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_216:
    .rept 216
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_217:
    .rept 217
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_218:
    .rept 218
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_219:
    .rept 219
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_220:
    .rept 220
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_221:
    .rept 221
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_222:
    .rept 222
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_223:
    .rept 223
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_224:
    .rept 224
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_225:
    .rept 225
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_226:
    .rept 226
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_227:
    .rept 227
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_228:
    .rept 228
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_229:
    .rept 229
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_230:
    .rept 230
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_231:
    .rept 231
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_232:
    .rept 232
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_233:
    .rept 233
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_234:
    .rept 234
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_235:
    .rept 235
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_236:
    .rept 236
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_237:
    .rept 237
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_238:
    .rept 238
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_239:
    .rept 239
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_240:
    .rept 240
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_241:
    .rept 241
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_242:
    .rept 242
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_243:
    .rept 243
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_244:
    .rept 244
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_245:
    .rept 245
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_246:
    .rept 246
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_247:
    .rept 247
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_248:
    .rept 248
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_249:
    .rept 249
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_250:
    .rept 250
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_251:
    .rept 251
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_252:
    .rept 252
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_253:
    .rept 253
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_254:
    .rept 254
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_255:
    .rept 255
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.align 4
entry_256:
    .rept 256
        cmp xzr, xzr
        b.eq 1f
    1:
    .endr
    ret

.size dummy_chain, .-dummy_chain
