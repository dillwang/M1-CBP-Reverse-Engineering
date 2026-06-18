// ghr100_patterns.S  (GNU as, AArch64)
// Two functions:
//   void ghr100_pattern_A(long iters);
//   void ghr100_pattern_B(long iters);

    .text

    // --- Macros for dummy conditional branches --------------

    // Always TAKEN branch:
    //   mov x1,#1 ; cbnz x1,1f ; 1:
    .macro DUMMY_T
        mov x1, #1
        cbnz x1, 1f
1:
    .endm

    // Always NOT-TAKEN branch:
    //   mov x1,#0 ; cbnz x1,1f ; 1:
    .macro DUMMY_N
        mov x1, #0
        cbnz x1, 1f
1:
    .endm

    // Helper to bump global_sink in C so the code can’t be optimized away
    .macro TOUCH_SINK
        adrp x3, global_sink
        add  x3, x3, :lo12:global_sink
        ldr  w4, [x3]
        add  w4, w4, #1
        str  w4, [x3]
    .endm

    // -------------------------------------------------------------
    // void ghr100_pattern_A(long iters);
    //  - 100 dummy conditional branches:
    //      * first 99 are fixed (all TAKEN here, but you can change)
    //      * #100 is TAKEN  (bit = 1)
    //  - probe branch after that depends on (iters & 1)
    // -------------------------------------------------------------
    .global ghr100_pattern_A
    .type   ghr100_pattern_A, %function
ghr100_pattern_A:
    cbz x0, .Lend_A       // if iters == 0, return

.Lloop_A:
    // ---- History: first 99 branches (fixed pattern) ----
    // You can change this to any repeating T/N pattern you like.
    .rept 99
        DUMMY_T
    .endr

    // ---- History branch #100 (control bit) ----
    // In pattern A: TAKEN
    // In pattern B (below): NOT-TAKEN
    DUMMY_T    // *** THIS IS HISTORY BIT #100 IN PATTERN A ***

    // ---- Probe branch ----
    // Depends on (iters & 1). We keep x0 as the loop counter.
    and x2, x0, #1
    cbnz x2, .Lprobe_taken_A   // if odd -> TAKEN, else fallthrough=NOT-TAKEN

.Lprobe_not_taken_A:
    TOUCH_SINK
    b .Lafter_probe_A

.Lprobe_taken_A:
    TOUCH_SINK

.Lafter_probe_A:
    // loop control
    subs x0, x0, #1
    b.ne .Lloop_A

.Lend_A:
    ret

    .size ghr100_pattern_A, .-ghr100_pattern_A

    // -------------------------------------------------------------
    // void ghr100_pattern_B(long iters);
    //  - Same as pattern A EXCEPT:
    //      history branch #100 is NOT TAKEN instead of TAKEN.
    //  - This flips one remote bit in the global history.
    // -------------------------------------------------------------
    .global ghr100_pattern_B
    .type   ghr100_pattern_B, %function
ghr100_pattern_B:
    cbz x0, .Lend_B

.Lloop_B:
    // First 99 branches identical to pattern A
    .rept 99
        DUMMY_T
    .endr

    // History branch #100: NOT-TAKEN here
    DUMMY_N    // *** THIS IS HISTORY BIT #100 IN PATTERN B ***

    // Same probe branch as in pattern A
    and x2, x0, #1
    cbnz x2, .Lprobe_taken_B

.Lprobe_not_taken_B:
    TOUCH_SINK
    b .Lafter_probe_B

.Lprobe_taken_B:
    TOUCH_SINK

.Lafter_probe_B:
    subs x0, x0, #1
    b.ne .Lloop_B

.Lend_B:
    ret

    .size ghr100_pattern_B, .-ghr100_pattern_B
