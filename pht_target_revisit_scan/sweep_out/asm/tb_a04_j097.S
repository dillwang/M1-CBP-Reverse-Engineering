
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
    // RNG seed
    movz    w20, #0x1234
    movk    w20, #0xBEEF, lsl #16

    // loop counter
    movz    w19, #0x86A0
    movk    w19, #0x0001, lsl #16

for_loop:
    // xorshift32
    eor     w20, w20, w20, lsl #13
    eor     w20, w20, w20, lsr #17
    eor     w20, w20, w20, lsl #5

    // random bit in w21
    and     w21, w20, #1

    // CLEAR #
    mov     w15, #102

    // clear loop body
    ldr     x16, =L_jump_clear
    br      x16

    .section .text.main, "ax"

    // CLEAR_PHR
    .global L_target_clear
L_target_clear:
    sub     w15, w15, #1

    .p2align 4

    .global L_jump_clear
L_jump_clear:
    cbnz    w15, L_target_clear

after_clear:
    cmp     w21, #0

    .p2align 4

    .global Train_Branch
Train_Branch:
    b.eq    lbl_tr

    .p2align 4
lbl_tr:
    nop

    bl      Do_Uncond_Jumps

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

    .section .text.uncond_jumps, "ax"
    .global Do_Uncond_Jumps
    .type   Do_Uncond_Jumps, %function
Do_Uncond_Jumps:
    b       uj_001
uj_001:
    b       uj_002
uj_002:
    b       uj_003
uj_003:
    b       uj_004
uj_004:
    b       uj_005
uj_005:
    b       uj_006
uj_006:
    b       uj_007
uj_007:
    b       uj_008
uj_008:
    b       uj_009
uj_009:
    b       uj_010
uj_010:
    b       uj_011
uj_011:
    b       uj_012
uj_012:
    b       uj_013
uj_013:
    b       uj_014
uj_014:
    b       uj_015
uj_015:
    b       uj_016
uj_016:
    b       uj_017
uj_017:
    b       uj_018
uj_018:
    b       uj_019
uj_019:
    b       uj_020
uj_020:
    b       uj_021
uj_021:
    b       uj_022
uj_022:
    b       uj_023
uj_023:
    b       uj_024
uj_024:
    b       uj_025
uj_025:
    b       uj_026
uj_026:
    b       uj_027
uj_027:
    b       uj_028
uj_028:
    b       uj_029
uj_029:
    b       uj_030
uj_030:
    b       uj_031
uj_031:
    b       uj_032
uj_032:
    b       uj_033
uj_033:
    b       uj_034
uj_034:
    b       uj_035
uj_035:
    b       uj_036
uj_036:
    b       uj_037
uj_037:
    b       uj_038
uj_038:
    b       uj_039
uj_039:
    b       uj_040
uj_040:
    b       uj_041
uj_041:
    b       uj_042
uj_042:
    b       uj_043
uj_043:
    b       uj_044
uj_044:
    b       uj_045
uj_045:
    b       uj_046
uj_046:
    b       uj_047
uj_047:
    b       uj_048
uj_048:
    b       uj_049
uj_049:
    b       uj_050
uj_050:
    b       uj_051
uj_051:
    b       uj_052
uj_052:
    b       uj_053
uj_053:
    b       uj_054
uj_054:
    b       uj_055
uj_055:
    b       uj_056
uj_056:
    b       uj_057
uj_057:
    b       uj_058
uj_058:
    b       uj_059
uj_059:
    b       uj_060
uj_060:
    b       uj_061
uj_061:
    b       uj_062
uj_062:
    b       uj_063
uj_063:
    b       uj_064
uj_064:
    b       uj_065
uj_065:
    b       uj_066
uj_066:
    b       uj_067
uj_067:
    b       uj_068
uj_068:
    b       uj_069
uj_069:
    b       uj_070
uj_070:
    b       uj_071
uj_071:
    b       uj_072
uj_072:
    b       uj_073
uj_073:
    b       uj_074
uj_074:
    b       uj_075
uj_075:
    b       uj_076
uj_076:
    b       uj_077
uj_077:
    b       uj_078
uj_078:
    b       uj_079
uj_079:
    b       uj_080
uj_080:
    b       uj_081
uj_081:
    b       uj_082
uj_082:
    b       uj_083
uj_083:
    b       uj_084
uj_084:
    b       uj_085
uj_085:
    b       uj_086
uj_086:
    b       uj_087
uj_087:
    b       uj_088
uj_088:
    b       uj_089
uj_089:
    b       uj_090
uj_090:
    b       uj_091
uj_091:
    b       uj_092
uj_092:
    b       uj_093
uj_093:
    b       uj_094
uj_094:
    b       uj_095
uj_095:
    b       uj_096
uj_096:
    b       uj_097
uj_097:
    ret

