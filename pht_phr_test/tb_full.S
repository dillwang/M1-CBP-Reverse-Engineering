    .text
    .align 2

.section .text.startup, "ax"
.global _start
.type _start, %function
_start:
    // seed
    mov     w20, #0x1234
    movk    w20, #0xBEEF, lsl #16

    # // N = 100,000
    # mov     w19, #0x86A0
    # movk    w19, #0x0001, lsl #16
    // N = 1,000,000
    mov     w19, #0x4240
    movk    w19, #0x000F, lsl #16

1:  // xorshift32
    eor     w20, w20, w20, lsl #13
    eor     w20, w20, w20, lsr #17
    eor     w20, w20, w20, lsl #5

    // k = x & 1  (k in w0)
    and     w0, w20, #1
    mov     w17, w0

    // Call branch1
    ldr x16, =branch1
    blr x16

    ldr x16, =branch2
    blr x16

    ldr x16, =branch3
    blr x16

    ldr x16, =branch4
    blr x16

    // Call branch2
    ldr x16, =branch5
    blr x16

    ldr x16, =branch6
    blr x16

    ldr x16, =branch7
    blr x16

    ldr x16, =branch8
    blr x16

    subs    w19, w19, #1
    b.ne    1b

    // exit
    mov     x0, #0
    mov     x8, #93
    svc     #0
.size _start, .-_start
.ltorg


.macro BUILD_BRANCH_FUNC func_name, set_phr_func, cond_taken
.section .\func_name, "ax"
.global \func_name
.type \func_name, %function

\func_name:
    stp     x29, x30, [sp, -16]!
    mov     x29, sp

    // Call the shared PHR setter.
    // w0 already contains k and is preserved by the setter.
    ldr     x16, =\set_phr_func
\func_name\()_setFunction:
    blr     x16

\func_name\()_probe:
    cmp     w17, #0

    .if \cond_taken == 0
        b.eq    \func_name\()_taken
    .else
        b.ne    \func_name\()_taken
    .endif

\func_name\()_fall:
    ldp     x29, x30, [sp], 16
    ret

\func_name\()_taken:
    ldp     x29, x30, [sp], 16
    ret

.size \func_name, .-\func_name
.endm

// Reference group: branch1-branch4
BUILD_BRANCH_FUNC branch1, func_set_phr_ref, 1
BUILD_BRANCH_FUNC branch2, func_set_phr_ref, 1
BUILD_BRANCH_FUNC branch3, func_set_phr_ref, 1
BUILD_BRANCH_FUNC branch4, func_set_phr_ref, 1

// Shifted-test group: branch5-branch8
BUILD_BRANCH_FUNC branch5, func_set_phr_test, 1
BUILD_BRANCH_FUNC branch6, func_set_phr_test, 1
BUILD_BRANCH_FUNC branch7, func_set_phr_test, 1
BUILD_BRANCH_FUNC branch8, func_set_phr_test, 1


// =============================================================================
// Slot format
//   - Every slot is exactly 0x14 bytes = 5 instructions
//   - Dummy slot: 4 nops + 1 unconditional branch
//   - Inject slot: cmp + b.eq + b.ne + 2 distinct target labels
// =============================================================================

.macro DUMMY_SLOT name, next
\name:
    nop
    nop
    nop
    nop
    b       \next
.endm

.macro INJECT_SLOT name, next, l0, l1
\name:
    cmp     w17, #0
    b.eq    \l0
    b.ne    \l1
\l0:
    b       \next
\l1:
    b       \next
.endm

// =============================================================================
// BUILD_SET_PHR_FUNC func_name, inject_pos
//
// Builds a 100-slot function.
//   - slot 0 .. slot 99
//   - exactly one slot is the inject slot
//   - final slot branches to ret label
//
// Notes:
//   - w0 holds k
//   - inject_pos must be 0..99
// =============================================================================

.macro BUILD_SET_PHR_FUNC func_name, inject_pos
    .global \func_name
    .type   \func_name, %function

\func_name:

    // ---- slot 0 ----
    .if \inject_pos == 0
        INJECT_SLOT \func_name\()_slot0, \func_name\()_slot1, \func_name\()_slot0_0, \func_name\()_slot0_1
    .else
        DUMMY_SLOT  \func_name\()_slot0, \func_name\()_slot1
    .endif

    // ---- slot 1 ----
    .if \inject_pos == 1
        INJECT_SLOT \func_name\()_slot1, \func_name\()_slot2, \func_name\()_slot1_0, \func_name\()_slot1_1
    .else
        DUMMY_SLOT  \func_name\()_slot1, \func_name\()_slot2
    .endif

    // ---- slot 2 ----
    .if \inject_pos == 2
        INJECT_SLOT \func_name\()_slot2, \func_name\()_slot3, \func_name\()_slot2_0, \func_name\()_slot2_1
    .else
        DUMMY_SLOT  \func_name\()_slot2, \func_name\()_slot3
    .endif

    // ---- slot 3 ----
    .if \inject_pos == 3
        INJECT_SLOT \func_name\()_slot3, \func_name\()_slot4, \func_name\()_slot3_0, \func_name\()_slot3_1
    .else
        DUMMY_SLOT  \func_name\()_slot3, \func_name\()_slot4
    .endif

    // ---- slot 4 ----
    .if \inject_pos == 4
        INJECT_SLOT \func_name\()_slot4, \func_name\()_slot5, \func_name\()_slot4_0, \func_name\()_slot4_1
    .else
        DUMMY_SLOT  \func_name\()_slot4, \func_name\()_slot5
    .endif

    // ---- slot 5 ----
    .if \inject_pos == 5
        INJECT_SLOT \func_name\()_slot5, \func_name\()_slot6, \func_name\()_slot5_0, \func_name\()_slot5_1
    .else
        DUMMY_SLOT  \func_name\()_slot5, \func_name\()_slot6
    .endif

    // ---- slot 6 ----
    .if \inject_pos == 6
        INJECT_SLOT \func_name\()_slot6, \func_name\()_slot7, \func_name\()_slot6_0, \func_name\()_slot6_1
    .else
        DUMMY_SLOT  \func_name\()_slot6, \func_name\()_slot7
    .endif

    // ---- slot 7 ----
    .if \inject_pos == 7
        INJECT_SLOT \func_name\()_slot7, \func_name\()_slot8, \func_name\()_slot7_0, \func_name\()_slot7_1
    .else
        DUMMY_SLOT  \func_name\()_slot7, \func_name\()_slot8
    .endif

    // ---- slot 8 ----
    .if \inject_pos == 8
        INJECT_SLOT \func_name\()_slot8, \func_name\()_slot9, \func_name\()_slot8_0, \func_name\()_slot8_1
    .else
        DUMMY_SLOT  \func_name\()_slot8, \func_name\()_slot9
    .endif

    // ---- slot 9 ----
    .if \inject_pos == 9
        INJECT_SLOT \func_name\()_slot9, \func_name\()_slot10, \func_name\()_slot9_0, \func_name\()_slot9_1
    .else
        DUMMY_SLOT  \func_name\()_slot9, \func_name\()_slot10
    .endif

    // ---- slot 10 ----
    .if \inject_pos == 10
        INJECT_SLOT \func_name\()_slot10, \func_name\()_slot11, \func_name\()_slot10_0, \func_name\()_slot10_1
    .else
        DUMMY_SLOT  \func_name\()_slot10, \func_name\()_slot11
    .endif

    // ---- slot 11 ----
    .if \inject_pos == 11
        INJECT_SLOT \func_name\()_slot11, \func_name\()_slot12, \func_name\()_slot11_0, \func_name\()_slot11_1
    .else
        DUMMY_SLOT  \func_name\()_slot11, \func_name\()_slot12
    .endif

    // ---- slot 12 ----
    .if \inject_pos == 12
        INJECT_SLOT \func_name\()_slot12, \func_name\()_slot13, \func_name\()_slot12_0, \func_name\()_slot12_1
    .else
        DUMMY_SLOT  \func_name\()_slot12, \func_name\()_slot13
    .endif

    // ---- slot 13 ----
    .if \inject_pos == 13
        INJECT_SLOT \func_name\()_slot13, \func_name\()_slot14, \func_name\()_slot13_0, \func_name\()_slot13_1
    .else
        DUMMY_SLOT  \func_name\()_slot13, \func_name\()_slot14
    .endif

    // ---- slot 14 ----
    .if \inject_pos == 14
        INJECT_SLOT \func_name\()_slot14, \func_name\()_slot15, \func_name\()_slot14_0, \func_name\()_slot14_1
    .else
        DUMMY_SLOT  \func_name\()_slot14, \func_name\()_slot15
    .endif

    // ---- slot 15 ----
    .if \inject_pos == 15
        INJECT_SLOT \func_name\()_slot15, \func_name\()_slot16, \func_name\()_slot15_0, \func_name\()_slot15_1
    .else
        DUMMY_SLOT  \func_name\()_slot15, \func_name\()_slot16
    .endif

    // ---- slot 16 ----
    .if \inject_pos == 16
        INJECT_SLOT \func_name\()_slot16, \func_name\()_slot17, \func_name\()_slot16_0, \func_name\()_slot16_1
    .else
        DUMMY_SLOT  \func_name\()_slot16, \func_name\()_slot17
    .endif

    // ---- slot 17 ----
    .if \inject_pos == 17
        INJECT_SLOT \func_name\()_slot17, \func_name\()_slot18, \func_name\()_slot17_0, \func_name\()_slot17_1
    .else
        DUMMY_SLOT  \func_name\()_slot17, \func_name\()_slot18
    .endif

    // ---- slot 18 ----
    .if \inject_pos == 18
        INJECT_SLOT \func_name\()_slot18, \func_name\()_slot19, \func_name\()_slot18_0, \func_name\()_slot18_1
    .else
        DUMMY_SLOT  \func_name\()_slot18, \func_name\()_slot19
    .endif

    // ---- slot 19 ----
    .if \inject_pos == 19
        INJECT_SLOT \func_name\()_slot19, \func_name\()_slot20, \func_name\()_slot19_0, \func_name\()_slot19_1
    .else
        DUMMY_SLOT  \func_name\()_slot19, \func_name\()_slot20
    .endif

    // ---- slot 20 ----
    .if \inject_pos == 20
        INJECT_SLOT \func_name\()_slot20, \func_name\()_slot21, \func_name\()_slot20_0, \func_name\()_slot20_1
    .else
        DUMMY_SLOT  \func_name\()_slot20, \func_name\()_slot21
    .endif

    // ---- slot 21 ----
    .if \inject_pos == 21
        INJECT_SLOT \func_name\()_slot21, \func_name\()_slot22, \func_name\()_slot21_0, \func_name\()_slot21_1
    .else
        DUMMY_SLOT  \func_name\()_slot21, \func_name\()_slot22
    .endif

    // ---- slot 22 ----
    .if \inject_pos == 22
        INJECT_SLOT \func_name\()_slot22, \func_name\()_slot23, \func_name\()_slot22_0, \func_name\()_slot22_1
    .else
        DUMMY_SLOT  \func_name\()_slot22, \func_name\()_slot23
    .endif

    // ---- slot 23 ----
    .if \inject_pos == 23
        INJECT_SLOT \func_name\()_slot23, \func_name\()_slot24, \func_name\()_slot23_0, \func_name\()_slot23_1
    .else
        DUMMY_SLOT  \func_name\()_slot23, \func_name\()_slot24
    .endif

    // ---- slot 24 ----
    .if \inject_pos == 24
        INJECT_SLOT \func_name\()_slot24, \func_name\()_slot25, \func_name\()_slot24_0, \func_name\()_slot24_1
    .else
        DUMMY_SLOT  \func_name\()_slot24, \func_name\()_slot25
    .endif

    // ---- slot 25 ----
    .if \inject_pos == 25
        INJECT_SLOT \func_name\()_slot25, \func_name\()_slot26, \func_name\()_slot25_0, \func_name\()_slot25_1
    .else
        DUMMY_SLOT  \func_name\()_slot25, \func_name\()_slot26
    .endif

    // ---- slot 26 ----
    .if \inject_pos == 26
        INJECT_SLOT \func_name\()_slot26, \func_name\()_slot27, \func_name\()_slot26_0, \func_name\()_slot26_1
    .else
        DUMMY_SLOT  \func_name\()_slot26, \func_name\()_slot27
    .endif

    // ---- slot 27 ----
    .if \inject_pos == 27
        INJECT_SLOT \func_name\()_slot27, \func_name\()_slot28, \func_name\()_slot27_0, \func_name\()_slot27_1
    .else
        DUMMY_SLOT  \func_name\()_slot27, \func_name\()_slot28
    .endif

    // ---- slot 28 ----
    .if \inject_pos == 28
        INJECT_SLOT \func_name\()_slot28, \func_name\()_slot29, \func_name\()_slot28_0, \func_name\()_slot28_1
    .else
        DUMMY_SLOT  \func_name\()_slot28, \func_name\()_slot29
    .endif

    // ---- slot 29 ----
    .if \inject_pos == 29
        INJECT_SLOT \func_name\()_slot29, \func_name\()_slot30, \func_name\()_slot29_0, \func_name\()_slot29_1
    .else
        DUMMY_SLOT  \func_name\()_slot29, \func_name\()_slot30
    .endif

    // ---- slot 30 ----
    .if \inject_pos == 30
        INJECT_SLOT \func_name\()_slot30, \func_name\()_slot31, \func_name\()_slot30_0, \func_name\()_slot30_1
    .else
        DUMMY_SLOT  \func_name\()_slot30, \func_name\()_slot31
    .endif

    // ---- slot 31 ----
    .if \inject_pos == 31
        INJECT_SLOT \func_name\()_slot31, \func_name\()_slot32, \func_name\()_slot31_0, \func_name\()_slot31_1
    .else
        DUMMY_SLOT  \func_name\()_slot31, \func_name\()_slot32
    .endif

    // ---- slot 32 ----
    .if \inject_pos == 32
        INJECT_SLOT \func_name\()_slot32, \func_name\()_slot33, \func_name\()_slot32_0, \func_name\()_slot32_1
    .else
        DUMMY_SLOT  \func_name\()_slot32, \func_name\()_slot33
    .endif

    // ---- slot 33 ----
    .if \inject_pos == 33
        INJECT_SLOT \func_name\()_slot33, \func_name\()_slot34, \func_name\()_slot33_0, \func_name\()_slot33_1
    .else
        DUMMY_SLOT  \func_name\()_slot33, \func_name\()_slot34
    .endif

    // ---- slot 34 ----
    .if \inject_pos == 34
        INJECT_SLOT \func_name\()_slot34, \func_name\()_slot35, \func_name\()_slot34_0, \func_name\()_slot34_1
    .else
        DUMMY_SLOT  \func_name\()_slot34, \func_name\()_slot35
    .endif

    // ---- slot 35 ----
    .if \inject_pos == 35
        INJECT_SLOT \func_name\()_slot35, \func_name\()_slot36, \func_name\()_slot35_0, \func_name\()_slot35_1
    .else
        DUMMY_SLOT  \func_name\()_slot35, \func_name\()_slot36
    .endif

    // ---- slot 36 ----
    .if \inject_pos == 36
        INJECT_SLOT \func_name\()_slot36, \func_name\()_slot37, \func_name\()_slot36_0, \func_name\()_slot36_1
    .else
        DUMMY_SLOT  \func_name\()_slot36, \func_name\()_slot37
    .endif

    // ---- slot 37 ----
    .if \inject_pos == 37
        INJECT_SLOT \func_name\()_slot37, \func_name\()_slot38, \func_name\()_slot37_0, \func_name\()_slot37_1
    .else
        DUMMY_SLOT  \func_name\()_slot37, \func_name\()_slot38
    .endif

    // ---- slot 38 ----
    .if \inject_pos == 38
        INJECT_SLOT \func_name\()_slot38, \func_name\()_slot39, \func_name\()_slot38_0, \func_name\()_slot38_1
    .else
        DUMMY_SLOT  \func_name\()_slot38, \func_name\()_slot39
    .endif

    // ---- slot 39 ----
    .if \inject_pos == 39
        INJECT_SLOT \func_name\()_slot39, \func_name\()_slot40, \func_name\()_slot39_0, \func_name\()_slot39_1
    .else
        DUMMY_SLOT  \func_name\()_slot39, \func_name\()_slot40
    .endif

    // ---- slot 40 ----
    .if \inject_pos == 40
        INJECT_SLOT \func_name\()_slot40, \func_name\()_slot41, \func_name\()_slot40_0, \func_name\()_slot40_1
    .else
        DUMMY_SLOT  \func_name\()_slot40, \func_name\()_slot41
    .endif

    // ---- slot 41 ----
    .if \inject_pos == 41
        INJECT_SLOT \func_name\()_slot41, \func_name\()_slot42, \func_name\()_slot41_0, \func_name\()_slot41_1
    .else
        DUMMY_SLOT  \func_name\()_slot41, \func_name\()_slot42
    .endif

    // ---- slot 42 ----
    .if \inject_pos == 42
        INJECT_SLOT \func_name\()_slot42, \func_name\()_slot43, \func_name\()_slot42_0, \func_name\()_slot42_1
    .else
        DUMMY_SLOT  \func_name\()_slot42, \func_name\()_slot43
    .endif

    // ---- slot 43 ----
    .if \inject_pos == 43
        INJECT_SLOT \func_name\()_slot43, \func_name\()_slot44, \func_name\()_slot43_0, \func_name\()_slot43_1
    .else
        DUMMY_SLOT  \func_name\()_slot43, \func_name\()_slot44
    .endif

    // ---- slot 44 ----
    .if \inject_pos == 44
        INJECT_SLOT \func_name\()_slot44, \func_name\()_slot45, \func_name\()_slot44_0, \func_name\()_slot44_1
    .else
        DUMMY_SLOT  \func_name\()_slot44, \func_name\()_slot45
    .endif

    // ---- slot 45 ----
    .if \inject_pos == 45
        INJECT_SLOT \func_name\()_slot45, \func_name\()_slot46, \func_name\()_slot45_0, \func_name\()_slot45_1
    .else
        DUMMY_SLOT  \func_name\()_slot45, \func_name\()_slot46
    .endif

    // ---- slot 46 ----
    .if \inject_pos == 46
        INJECT_SLOT \func_name\()_slot46, \func_name\()_slot47, \func_name\()_slot46_0, \func_name\()_slot46_1
    .else
        DUMMY_SLOT  \func_name\()_slot46, \func_name\()_slot47
    .endif

    // ---- slot 47 ----
    .if \inject_pos == 47
        INJECT_SLOT \func_name\()_slot47, \func_name\()_slot48, \func_name\()_slot47_0, \func_name\()_slot47_1
    .else
        DUMMY_SLOT  \func_name\()_slot47, \func_name\()_slot48
    .endif

    // ---- slot 48 ----
    .if \inject_pos == 48
        INJECT_SLOT \func_name\()_slot48, \func_name\()_slot49, \func_name\()_slot48_0, \func_name\()_slot48_1
    .else
        DUMMY_SLOT  \func_name\()_slot48, \func_name\()_slot49
    .endif

    // ---- slot 49 ----
    .if \inject_pos == 49
        INJECT_SLOT \func_name\()_slot49, \func_name\()_slot50, \func_name\()_slot49_0, \func_name\()_slot49_1
    .else
        DUMMY_SLOT  \func_name\()_slot49, \func_name\()_slot50
    .endif

    // ---- slot 50 ----
    .if \inject_pos == 50
        INJECT_SLOT \func_name\()_slot50, \func_name\()_slot51, \func_name\()_slot50_0, \func_name\()_slot50_1
    .else
        DUMMY_SLOT  \func_name\()_slot50, \func_name\()_slot51
    .endif

    // ---- slot 51 ----
    .if \inject_pos == 51
        INJECT_SLOT \func_name\()_slot51, \func_name\()_slot52, \func_name\()_slot51_0, \func_name\()_slot51_1
    .else
        DUMMY_SLOT  \func_name\()_slot51, \func_name\()_slot52
    .endif

    // ---- slot 52 ----
    .if \inject_pos == 52
        INJECT_SLOT \func_name\()_slot52, \func_name\()_slot53, \func_name\()_slot52_0, \func_name\()_slot52_1
    .else
        DUMMY_SLOT  \func_name\()_slot52, \func_name\()_slot53
    .endif

    // ---- slot 53 ----
    .if \inject_pos == 53
        INJECT_SLOT \func_name\()_slot53, \func_name\()_slot54, \func_name\()_slot53_0, \func_name\()_slot53_1
    .else
        DUMMY_SLOT  \func_name\()_slot53, \func_name\()_slot54
    .endif

    // ---- slot 54 ----
    .if \inject_pos == 54
        INJECT_SLOT \func_name\()_slot54, \func_name\()_slot55, \func_name\()_slot54_0, \func_name\()_slot54_1
    .else
        DUMMY_SLOT  \func_name\()_slot54, \func_name\()_slot55
    .endif

    // ---- slot 55 ----
    .if \inject_pos == 55
        INJECT_SLOT \func_name\()_slot55, \func_name\()_slot56, \func_name\()_slot55_0, \func_name\()_slot55_1
    .else
        DUMMY_SLOT  \func_name\()_slot55, \func_name\()_slot56
    .endif

    // ---- slot 56 ----
    .if \inject_pos == 56
        INJECT_SLOT \func_name\()_slot56, \func_name\()_slot57, \func_name\()_slot56_0, \func_name\()_slot56_1
    .else
        DUMMY_SLOT  \func_name\()_slot56, \func_name\()_slot57
    .endif

    // ---- slot 57 ----
    .if \inject_pos == 57
        INJECT_SLOT \func_name\()_slot57, \func_name\()_slot58, \func_name\()_slot57_0, \func_name\()_slot57_1
    .else
        DUMMY_SLOT  \func_name\()_slot57, \func_name\()_slot58
    .endif

    // ---- slot 58 ----
    .if \inject_pos == 58
        INJECT_SLOT \func_name\()_slot58, \func_name\()_slot59, \func_name\()_slot58_0, \func_name\()_slot58_1
    .else
        DUMMY_SLOT  \func_name\()_slot58, \func_name\()_slot59
    .endif

    // ---- slot 59 ----
    .if \inject_pos == 59
        INJECT_SLOT \func_name\()_slot59, \func_name\()_slot60, \func_name\()_slot59_0, \func_name\()_slot59_1
    .else
        DUMMY_SLOT  \func_name\()_slot59, \func_name\()_slot60
    .endif

    // ---- slot 60 ----
    .if \inject_pos == 60
        INJECT_SLOT \func_name\()_slot60, \func_name\()_slot61, \func_name\()_slot60_0, \func_name\()_slot60_1
    .else
        DUMMY_SLOT  \func_name\()_slot60, \func_name\()_slot61
    .endif

    // ---- slot 61 ----
    .if \inject_pos == 61
        INJECT_SLOT \func_name\()_slot61, \func_name\()_slot62, \func_name\()_slot61_0, \func_name\()_slot61_1
    .else
        DUMMY_SLOT  \func_name\()_slot61, \func_name\()_slot62
    .endif

    // ---- slot 62 ----
    .if \inject_pos == 62
        INJECT_SLOT \func_name\()_slot62, \func_name\()_slot63, \func_name\()_slot62_0, \func_name\()_slot62_1
    .else
        DUMMY_SLOT  \func_name\()_slot62, \func_name\()_slot63
    .endif

    // ---- slot 63 ----
    .if \inject_pos == 63
        INJECT_SLOT \func_name\()_slot63, \func_name\()_slot64, \func_name\()_slot63_0, \func_name\()_slot63_1
    .else
        DUMMY_SLOT  \func_name\()_slot63, \func_name\()_slot64
    .endif

    // ---- slot 64 ----
    .if \inject_pos == 64
        INJECT_SLOT \func_name\()_slot64, \func_name\()_slot65, \func_name\()_slot64_0, \func_name\()_slot64_1
    .else
        DUMMY_SLOT  \func_name\()_slot64, \func_name\()_slot65
    .endif

    // ---- slot 65 ----
    .if \inject_pos == 65
        INJECT_SLOT \func_name\()_slot65, \func_name\()_slot66, \func_name\()_slot65_0, \func_name\()_slot65_1
    .else
        DUMMY_SLOT  \func_name\()_slot65, \func_name\()_slot66
    .endif

    // ---- slot 66 ----
    .if \inject_pos == 66
        INJECT_SLOT \func_name\()_slot66, \func_name\()_slot67, \func_name\()_slot66_0, \func_name\()_slot66_1
    .else
        DUMMY_SLOT  \func_name\()_slot66, \func_name\()_slot67
    .endif

    // ---- slot 67 ----
    .if \inject_pos == 67
        INJECT_SLOT \func_name\()_slot67, \func_name\()_slot68, \func_name\()_slot67_0, \func_name\()_slot67_1
    .else
        DUMMY_SLOT  \func_name\()_slot67, \func_name\()_slot68
    .endif

    // ---- slot 68 ----
    .if \inject_pos == 68
        INJECT_SLOT \func_name\()_slot68, \func_name\()_slot69, \func_name\()_slot68_0, \func_name\()_slot68_1
    .else
        DUMMY_SLOT  \func_name\()_slot68, \func_name\()_slot69
    .endif

    // ---- slot 69 ----
    .if \inject_pos == 69
        INJECT_SLOT \func_name\()_slot69, \func_name\()_slot70, \func_name\()_slot69_0, \func_name\()_slot69_1
    .else
        DUMMY_SLOT  \func_name\()_slot69, \func_name\()_slot70
    .endif

    // ---- slot 70 ----
    .if \inject_pos == 70
        INJECT_SLOT \func_name\()_slot70, \func_name\()_slot71, \func_name\()_slot70_0, \func_name\()_slot70_1
    .else
        DUMMY_SLOT  \func_name\()_slot70, \func_name\()_slot71
    .endif

    // ---- slot 71 ----
    .if \inject_pos == 71
        INJECT_SLOT \func_name\()_slot71, \func_name\()_slot72, \func_name\()_slot71_0, \func_name\()_slot71_1
    .else
        DUMMY_SLOT  \func_name\()_slot71, \func_name\()_slot72
    .endif

    // ---- slot 72 ----
    .if \inject_pos == 72
        INJECT_SLOT \func_name\()_slot72, \func_name\()_slot73, \func_name\()_slot72_0, \func_name\()_slot72_1
    .else
        DUMMY_SLOT  \func_name\()_slot72, \func_name\()_slot73
    .endif

    // ---- slot 73 ----
    .if \inject_pos == 73
        INJECT_SLOT \func_name\()_slot73, \func_name\()_slot74, \func_name\()_slot73_0, \func_name\()_slot73_1
    .else
        DUMMY_SLOT  \func_name\()_slot73, \func_name\()_slot74
    .endif

    // ---- slot 74 ----
    .if \inject_pos == 74
        INJECT_SLOT \func_name\()_slot74, \func_name\()_slot75, \func_name\()_slot74_0, \func_name\()_slot74_1
    .else
        DUMMY_SLOT  \func_name\()_slot74, \func_name\()_slot75
    .endif

    // ---- slot 75 ----
    .if \inject_pos == 75
        INJECT_SLOT \func_name\()_slot75, \func_name\()_slot76, \func_name\()_slot75_0, \func_name\()_slot75_1
    .else
        DUMMY_SLOT  \func_name\()_slot75, \func_name\()_slot76
    .endif

    // ---- slot 76 ----
    .if \inject_pos == 76
        INJECT_SLOT \func_name\()_slot76, \func_name\()_slot77, \func_name\()_slot76_0, \func_name\()_slot76_1
    .else
        DUMMY_SLOT  \func_name\()_slot76, \func_name\()_slot77
    .endif

    // ---- slot 77 ----
    .if \inject_pos == 77
        INJECT_SLOT \func_name\()_slot77, \func_name\()_slot78, \func_name\()_slot77_0, \func_name\()_slot77_1
    .else
        DUMMY_SLOT  \func_name\()_slot77, \func_name\()_slot78
    .endif

    // ---- slot 78 ----
    .if \inject_pos == 78
        INJECT_SLOT \func_name\()_slot78, \func_name\()_slot79, \func_name\()_slot78_0, \func_name\()_slot78_1
    .else
        DUMMY_SLOT  \func_name\()_slot78, \func_name\()_slot79
    .endif

    // ---- slot 79 ----
    .if \inject_pos == 79
        INJECT_SLOT \func_name\()_slot79, \func_name\()_slot80, \func_name\()_slot79_0, \func_name\()_slot79_1
    .else
        DUMMY_SLOT  \func_name\()_slot79, \func_name\()_slot80
    .endif

    // ---- slot 80 ----
    .if \inject_pos == 80
        INJECT_SLOT \func_name\()_slot80, \func_name\()_slot81, \func_name\()_slot80_0, \func_name\()_slot80_1
    .else
        DUMMY_SLOT  \func_name\()_slot80, \func_name\()_slot81
    .endif

    // ---- slot 81 ----
    .if \inject_pos == 81
        INJECT_SLOT \func_name\()_slot81, \func_name\()_slot82, \func_name\()_slot81_0, \func_name\()_slot81_1
    .else
        DUMMY_SLOT  \func_name\()_slot81, \func_name\()_slot82
    .endif

    // ---- slot 82 ----
    .if \inject_pos == 82
        INJECT_SLOT \func_name\()_slot82, \func_name\()_slot83, \func_name\()_slot82_0, \func_name\()_slot82_1
    .else
        DUMMY_SLOT  \func_name\()_slot82, \func_name\()_slot83
    .endif

    // ---- slot 83 ----
    .if \inject_pos == 83
        INJECT_SLOT \func_name\()_slot83, \func_name\()_slot84, \func_name\()_slot83_0, \func_name\()_slot83_1
    .else
        DUMMY_SLOT  \func_name\()_slot83, \func_name\()_slot84
    .endif

    // ---- slot 84 ----
    .if \inject_pos == 84
        INJECT_SLOT \func_name\()_slot84, \func_name\()_slot85, \func_name\()_slot84_0, \func_name\()_slot84_1
    .else
        DUMMY_SLOT  \func_name\()_slot84, \func_name\()_slot85
    .endif

    // ---- slot 85 ----
    .if \inject_pos == 85
        INJECT_SLOT \func_name\()_slot85, \func_name\()_slot86, \func_name\()_slot85_0, \func_name\()_slot85_1
    .else
        DUMMY_SLOT  \func_name\()_slot85, \func_name\()_slot86
    .endif

    // ---- slot 86 ----
    .if \inject_pos == 86
        INJECT_SLOT \func_name\()_slot86, \func_name\()_slot87, \func_name\()_slot86_0, \func_name\()_slot86_1
    .else
        DUMMY_SLOT  \func_name\()_slot86, \func_name\()_slot87
    .endif

    // ---- slot 87 ----
    .if \inject_pos == 87
        INJECT_SLOT \func_name\()_slot87, \func_name\()_slot88, \func_name\()_slot87_0, \func_name\()_slot87_1
    .else
        DUMMY_SLOT  \func_name\()_slot87, \func_name\()_slot88
    .endif

    // ---- slot 88 ----
    .if \inject_pos == 88
        INJECT_SLOT \func_name\()_slot88, \func_name\()_slot89, \func_name\()_slot88_0, \func_name\()_slot88_1
    .else
        DUMMY_SLOT  \func_name\()_slot88, \func_name\()_slot89
    .endif

    // ---- slot 89 ----
    .if \inject_pos == 89
        INJECT_SLOT \func_name\()_slot89, \func_name\()_slot90, \func_name\()_slot89_0, \func_name\()_slot89_1
    .else
        DUMMY_SLOT  \func_name\()_slot89, \func_name\()_slot90
    .endif

    // ---- slot 90 ----
    .if \inject_pos == 90
        INJECT_SLOT \func_name\()_slot90, \func_name\()_slot91, \func_name\()_slot90_0, \func_name\()_slot90_1
    .else
        DUMMY_SLOT  \func_name\()_slot90, \func_name\()_slot91
    .endif

    // ---- slot 91 ----
    .if \inject_pos == 91
        INJECT_SLOT \func_name\()_slot91, \func_name\()_slot92, \func_name\()_slot91_0, \func_name\()_slot91_1
    .else
        DUMMY_SLOT  \func_name\()_slot91, \func_name\()_slot92
    .endif

    // ---- slot 92 ----
    .if \inject_pos == 92
        INJECT_SLOT \func_name\()_slot92, \func_name\()_slot93, \func_name\()_slot92_0, \func_name\()_slot92_1
    .else
        DUMMY_SLOT  \func_name\()_slot92, \func_name\()_slot93
    .endif

    // ---- slot 93 ----
    .if \inject_pos == 93
        INJECT_SLOT \func_name\()_slot93, \func_name\()_slot94, \func_name\()_slot93_0, \func_name\()_slot93_1
    .else
        DUMMY_SLOT  \func_name\()_slot93, \func_name\()_slot94
    .endif

    // ---- slot 94 ----
    .if \inject_pos == 94
        INJECT_SLOT \func_name\()_slot94, \func_name\()_slot95, \func_name\()_slot94_0, \func_name\()_slot94_1
    .else
        DUMMY_SLOT  \func_name\()_slot94, \func_name\()_slot95
    .endif

    // ---- slot 95 ----
    .if \inject_pos == 95
        INJECT_SLOT \func_name\()_slot95, \func_name\()_slot96, \func_name\()_slot95_0, \func_name\()_slot95_1
    .else
        DUMMY_SLOT  \func_name\()_slot95, \func_name\()_slot96
    .endif

    // ---- slot 96 ----
    .if \inject_pos == 96
        INJECT_SLOT \func_name\()_slot96, \func_name\()_slot97, \func_name\()_slot96_0, \func_name\()_slot96_1
    .else
        DUMMY_SLOT  \func_name\()_slot96, \func_name\()_slot97
    .endif

    // ---- slot 97 ----
    .if \inject_pos == 97
        INJECT_SLOT \func_name\()_slot97, \func_name\()_ret, \func_name\()_slot97_0, \func_name\()_slot97_1
    .else
        DUMMY_SLOT  \func_name\()_slot97, \func_name\()_ret
    .endif

    /* 
    .if \inject_pos == 98
        INJECT_SLOT \func_name\()_slot98, \func_name\()_slot99, \func_name\()_slot98_0, \func_name\()_slot98_1
    .else
        DUMMY_SLOT  \func_name\()_slot98, \func_name\()_slot99
    .endif

    // ---- slot 99 ----
    .if \inject_pos == 99
        INJECT_SLOT \func_name\()_slot99, \func_name\()_ret, \func_name\()_slot99_0, \func_name\()_slot99_1
    .else
        DUMMY_SLOT  \func_name\()_slot99, \func_name\()_ret
    .endif 
    */

\func_name\()_ret:
    ret

    .size \func_name, .-\func_name
.endm

// =============================================================================
// Example usage
// =============================================================================

.set TEST_POS, 37

.section .phr_ref, "ax"
BUILD_SET_PHR_FUNC func_set_phr_ref, 0

.section .phr_test, "ax"
BUILD_SET_PHR_FUNC func_set_phr_test, TEST_POS
