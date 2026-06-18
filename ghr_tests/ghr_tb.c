// ghr_tb.c
// C wrapper for the AArch64 Hosein-style GHR test.

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

extern void ghr_test(long outer_iters, long inner_iters, long dummy_count);

volatile int global_sink = 0;  // touched from asm to keep things "alive"

int main(int argc, char **argv) {
    if (argc < 4) {
        fprintf(stderr,
            "Usage: %s <outer_iters> <inner_iters> <dummy_count>\n"
            "Example: %s 10 30000 100\n",
            argv[0], argv[0]);
        return 1;
    }

    long outer_iters = atol(argv[1]);   // repeat0
    long inner_iters = atol(argv[2]);   // repeat1
    long dummy_count = atol(argv[3]);   // dummy_count

    if (outer_iters <= 0 || inner_iters <= 0 || dummy_count < 0) {
        fprintf(stderr, "All iteration counts must be > 0, dummy_count >= 0\n");
        return 1;
    }

    // Tiny warmup to avoid cold start 
    for (int i = 0; i < 100000; i++) {
        global_sink++;
    }

    ghr_test(outer_iters, inner_iters, dummy_count);

    printf("Done: outer=%ld inner=%ld dummy=%ld sink=%d\n",
           outer_iters, inner_iters, dummy_count, global_sink);
    return 0;
}
