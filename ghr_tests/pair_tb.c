// hosein_pair_tb.c
// C wrapper for Hosein-style train/test branch experiment on AArch64.

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

extern void pair_test(long num_tries, long dummy_count);

volatile int global_sink = 0;  // used by asm to keep code "live"

int main(int argc, char **argv) {
    if (argc < 3) {
        fprintf(stderr,
            "Usage: %s <num_tries> <dummy_count>\n"
            "Example: %s 200000000 80\n",
            argv[0], argv[0]);
        return 1;
    }

    long num_tries  = atol(argv[1]);
    long dummy_count = atol(argv[2]);
    if (num_tries <= 0 || dummy_count < 0) {
        fprintf(stderr, "num_tries must be > 0, dummy_count >= 0\n");
        return 1;
    }

    // Tiny warmup
    for (int i = 0; i < 100000; i++) {
        global_sink++;
    }

    pair_test(num_tries, dummy_count);

    printf("Done: tries=%ld dummy=%ld sink=%d\n",
           num_tries, dummy_count, global_sink);
    return 0;
}
