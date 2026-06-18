// ghr_a64.S
// AArch64 version of GHR test pattern.

    .text
    .global ghr_test
    .type   ghr_test, %function

    .extern global_sink

    // ------------------------------------------------------------------
    // Static buffer for pseudo-random bits (0/1).
    // Size is arbitrary but should be "large enough" for your patterns.
    // ------------------------------------------------------------------
    .bss
    .align 4
    .global UserData
UserData:
    .space 65536        // 64 KB of bits

    .text

// ----------------------------------------------------------------------
// void ghr_test(long outer_iters, long inner_iters, long dummy_count)
//
// x0: outer_iters
// x1: inner_iters
// x2: dummy_count
//
// Pattern per *inner* iteration:
//   - bit = *ptr;
//   - First branch: if (bit == 1) branch;
//   - dummy_count "dummy" branches in between
//   - Second branch: if (bit == 1) branch;
//   - ptr++ with wrap-around
//
// Outer loop repeats this whole inner-loop pattern.
// ----------------------------------------------------------------------
ghr_test:
    // Prologue
    stp x29, x30, [sp, -16]!
    mov x29, sp
    stp x19, x20, [sp, -16]!
    stp x21, x22, [sp, -16]!
    stp x23, x24, [sp, -16]!

    // Save arguments
    mov x19, x0        // outer_iters
    mov x20, x1        // inner_iters
    mov x21, x2        // dummy_count

    // ------------------------------------------------------------------
    // Initialize UserData with pseudo-random 0/1 bytes using xorshift32
    // ------------------------------------------------------------------
    adrp x22, UserData
    add  x22, x22, :lo12:UserData   // x22 = base of UserData
    mov  x23, x22                   // x23 = write pointer
    mov  x24, #65536                // number of bytes to fill

    mov  w3, #1                     // RNG state (non-zero)

1:  // init_loop
    // xorshift32 in w3
    mov  w4, w3
    eor  w4, w4, w4, lsl #13
    eor  w4, w4, w4, lsr #17
    eor  w4, w4, w4, lsl #5
    mov  w3, w4

    // take lsb as bit
    and  w4, w4, #1
    strb w4, [x23]
    add  x23, x23, #1

    subs x24, x24, #1
    b.ne 1b

    // ------------------------------------------------------------------
    // GHR-style test loops
    // ------------------------------------------------------------------
    adrp x22, UserData
    add  x22, x22, :lo12:UserData   // x22 = base
    add  x24, x22, #65536           // x24 = end
    mov  x23, x22                   // x23 = ptr into UserData

outer_loop:
    cbz  x19, done          // if outer_iters == 0 -> done

    mov  x0, x20            // x0 = inner counter for this outer iteration

inner_loop:
    // --------------------------------------------------------------
    // FIRST BRANCH (depends on bit = *x23)
    // --------------------------------------------------------------
    ldrb w11, [x23]
    cmp  w11, #1
    beq  first_taken        // if bit == 1, branch taken

    // fall-through path for "not taken"
    .rept 100               // spacing nops
        nop
    .endr
first_taken:
    // --------------------------------------------------------------
    // Dummy branches: dummy_count always-taken "cmp; beq" pattern
    // (simplified multi-label version, but fills GHR)
    // --------------------------------------------------------------
    mov  x5, x21            // x5 = dummy_count
dummy_loop:
    cbz  x5, dummy_done     // if 0, done

    cmp  x6, x6             // always equal
    beq  dummy_target       // always taken
dummy_target:
    subs x5, x5, #1
    b    dummy_loop

dummy_done:
    // --------------------------------------------------------------
    // SECOND BRANCH (depends on same bit = *x23)
    // --------------------------------------------------------------
    ldrb w11, [x23]
    cmp  w11, #1
    beq  second_taken

    .rept 100
        nop
    .endr
second_taken:
    // --------------------------------------------------------------
    // Advance pointer into UserData, wrap at end
    // --------------------------------------------------------------
    add  x23, x23, #1
    cmp  x23, x24
    b.lo  no_wrap
    mov  x23, x22
no_wrap:

    // --------------------------------------------------------------
    // Optionally touch global_sink to keep the compiler honest
    // --------------------------------------------------------------
    adrp x3, global_sink
    add  x3, x3, :lo12:global_sink
    ldr  w4, [x3]
    add  w4, w4, #1
    str  w4, [x3]

    // inner loop control
    subs x0, x0, #1
    b.ne inner_loop

    // outer loop control
    subs x19, x19, #1
    b.ne outer_loop

done:
    // Epilogue
    ldp x23, x24, [sp], 16
    ldp x21, x22, [sp], 16
    ldp x19, x20, [sp], 16
    ldp x29, x30, [sp], 16
    ret

    .size ghr_test, .-ghr_test
