// pair_a64_inline.S
// Hosein-style train/test correlation experiment on AArch64
// with an INLINED unique-PC dummy chain (no function call/return).

    .text
    .global pair_test
    .type   pair_test, %function

    .extern global_sink

    .equ MAX_DUMMY, 256

// ----------------------------------------------------------------------
// void pair_test(long num_tries, long dummy_count)
//
// x0 = num_tries
// x1 = dummy_count (0..MAX_DUMMY)
//
// Per iteration:
//   k = random bit
//   if (k) ;             // TRAIN branch (random ~50% miss)
//   dummy_chain_inline(n)// n unique conditional branches (always taken)
//   if (k) ;             // TEST branch (correlated with train)
// ----------------------------------------------------------------------
pair_test:
    // Prologue
    stp x29, x30, [sp, -16]!
    mov x29, sp
    stp x19, x20, [sp, -16]!
    stp x21, x22, [sp, -16]!

    mov x19, x0        // tries
    mov x20, x1        // dummy_count

    mov w21, #1        // RNG state

loop_top:
    cbz x19, loop_done

    // xorshift32 -> w22, then k = w22 & 1
    mov  w22, w21
    eor  w22, w22, w22, lsl #13
    eor  w22, w22, w22, lsr #17
    eor  w22, w22, w22, lsl #5
    mov  w21, w22
    and  w22, w22, #1

    // ----------------------------
    // TRAIN: if (k) ;
    // ----------------------------
    cmp  w22, #0
    b.ne train_taken
    nop
    b   train_done
train_taken:
    nop
train_done:

    // ----------------------------
    // Inline dummy chain selection:
    // jump to entry_dummy_count
    // ----------------------------
    // Clamp dummy_count to MAX_DUMMY
    cmp x20, #MAX_DUMMY
    b.ls 1f
    mov x20, #MAX_DUMMY
1:
    // x1 = &dummy_jumptable
    adrp x1, dummy_jumptable
    add  x1, x1, :lo12:dummy_jumptable
    // x2 = dummy_jumptable[dummy_count]
    ldr  x2, [x1, x20, lsl #3]
    // branch to selected entry (no call/ret)
    br   x2

dummy_done:
    // ----------------------------
    // TEST: if (k) ;
    // ----------------------------
    cmp  w22, #0
    b.ne test_taken
    nop
    b   test_done
test_taken:
    nop
test_done:

    // Touch global_sink
    adrp x3, global_sink
    add  x3, x3, :lo12:global_sink
    ldr  w4, [x3]
    add  w4, w4, #1
    str  w4, [x3]

    // Loop
    subs x19, x19, #1
    b.ne loop_top

loop_done:
    // Epilogue
    ldp x21, x22, [sp], 16
    ldp x19, x20, [sp], 16
    ldp x29, x30, [sp], 16
    ret

    // ------------------------------------------------------------
    // Jump table + entries live in the SAME function (same file),
    // so selection doesn't inject call/ret history.
    // ------------------------------------------------------------
    .align 3
dummy_jumptable:
    // Filled by the included file below (addresses + entry bodies)
    .include "dummy_entries.inc"

    .size pair_test, .-pair_test
