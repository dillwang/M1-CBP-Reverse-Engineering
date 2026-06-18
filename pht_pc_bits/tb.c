#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

volatile uint64_t global_sink = 0;

extern void run_pht_align(uint64_t iters, uint32_t seed, uint32_t dummyN);

static void usage(const char *p) {
    fprintf(stderr, "Usage: %s <dummyN> <iters> <seed>\n", p);
    fprintf(stderr, "  dummyN: number of dummy-chain LINKS to execute for CLEAR step\n");
    fprintf(stderr, "  iters : number of iterations\n");
    fprintf(stderr, "  seed  : PRNG seed\n");
}

int main(int argc, char **argv) {
    if (argc < 4) { usage(argv[0]); return 2; }

    uint32_t dummyN = (uint32_t)strtoul(argv[1], 0, 0);
    uint64_t iters  = (uint64_t)strtoull(argv[2], 0, 0);
    uint32_t seed   = (uint32_t)strtoul(argv[3], 0, 0);

    run_pht_align(iters, seed, dummyN);

    printf("Done: sink=%llu\n", (unsigned long long)global_sink);
    return 0;
}
