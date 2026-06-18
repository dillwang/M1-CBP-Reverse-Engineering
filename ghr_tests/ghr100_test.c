// ghr100_test.c
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

extern void ghr100_pattern_A(long iters);
extern void ghr100_pattern_B(long iters);

volatile int global_sink = 0;  // for preventing dead-code elimination

int main(int argc, char **argv) {
    if (argc < 3) {
        fprintf(stderr, "Usage: %s A|B <iterations>\n", argv[0]);
        return 1;
    }

    long iters = atol(argv[2]);
    if (iters <= 0) {
        fprintf(stderr, "Iterations must be > 0\n");
        return 1;
    }

    // small warmup
    for (int i = 0; i < 100000; i++) {
        global_sink++;
    }

    if (argv[1][0] == 'A') {
        ghr100_pattern_A(iters);
    } else if (argv[1][0] == 'B') {
        ghr100_pattern_B(iters);
    } else {
        fprintf(stderr, "Unknown pattern '%s' (use A or B)\n", argv[1]);
        return 1;
    }

    printf("Done pattern %c, iters=%ld, sink=%d\n", argv[1][0], iters, global_sink);
    return 0;
}
