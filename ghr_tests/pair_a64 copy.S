// pair_a64.S
// style train/test correlation experiment on AArch64.

    .text
    .global pair_test
    .type   pair_test, %function

    .extern global_sink
    .extern dummy_chain

// ----------------------------------------------------------------------
// void pair_test(long num_tries, long dummy_count)
//
// x0 = num_tries      -- total iterations (NUM_TRIES)
// x1 = dummy_count    -- number of dummy branches between train & test
//
// Per iteration:
//   k = random bit
//   if (k) ;           // TRAIN branch (random, ~50% miss)
//   dummy_branches(n); // n dummy branches (always taken)
//   if (k) ;           // TEST branch (correlated with train)
// ----------------------------------------------------------------------
pair_test:
    // Prologue (save FP/LR and callee-saved regs)
    stp x29, x30, [sp, -16]!
    mov x29, sp
    stp x19, x20, [sp, -16]!
    stp x21, x22, [sp, -16]!

    mov x19, x0        // x19 = num_tries
    mov x20, x1        // x20 = dummy_count

    mov w21, #1        // RNG state (non-zero), in w21

loop_top:
    cbz x19, loop_done

    // --------------------------------------------------------------
    // Generate random bit k using xorshift32 in w21
    // --------------------------------------------------------------
    mov  w22, w21
    eor  w22, w22, w22, lsl #13
    eor  w22, w22, w22, lsr #17
    eor  w22, w22, w22, lsl #5
    mov  w21, w22        // update RNG state

    and  w22, w22, #1    // k = w22 & 1 (0 or 1)

    // --------------------------------------------------------------
    // TRAIN BRANCH: if (k) ;
    //  - This is the "hard" branch #1.
    // --------------------------------------------------------------
    cmp  w22, #0
    b.ne train_taken

    // not-taken path
    nop
    b   train_done

train_taken:
    nop

train_done:
    // --------------------------------------------------------------
    // Dummy branches: dummy_count always-taken conditionals
    //  cmp x3, x3  -> always equal
    //  b.eq ...    -> always taken
    // --------------------------------------------------------------
    mov x2, x20        // x2 = dummy counter

dummy_loop:
    cbz x2, dummy_done

    cmp x3, x3         // always equal
    b.eq dummy_taken
dummy_taken:
    subs x2, x2, #1
    b   dummy_loop

dummy_done:
    // --------------------------------------------------------------
    // TEST BRANCH: if (k) ;
    //  - This is the "probing" branch.
    // --------------------------------------------------------------
    cmp  w22, #0
    b.ne test_taken

    // not-taken path
    nop
    b   test_done

test_taken:
    nop

test_done:
    // --------------------------------------------------------------
    // Touch global_sink to keep things "live"
    // --------------------------------------------------------------
    adrp x3, global_sink
    add  x3, x3, :lo12:global_sink
    ldr  w4, [x3]
    add  w4, w4, #1
    str  w4, [x3]

    // Decrement tries and loop
    subs x19, x19, #1
    b.ne loop_top

loop_done:
    // Epilogue (restore regs in reverse order)
    ldp x21, x22, [sp], 16
    ldp x19, x20, [sp], 16
    ldp x29, x30, [sp], 16
    ret

    .size pair_test, .-pair_test
