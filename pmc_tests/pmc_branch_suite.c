#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

volatile int sink = 0;

static inline uint32_t xorshift32(uint32_t *state) {
    uint32_t x = *state;
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    *state = x;
    return x;
}

/*r8d =      all conditional branches
rc5 =      cond branch mispred
rc6 =       indirect mispred
rcb =      all branch mispred
*/

// 1)  predictable branch
void test_predictable(long iters) {
    volatile int local = 0;

    for (long i = 0; i < iters; i++) {
        if (i < iters - 1) {
            local++;
        } else {
            local--;
        }
    }

    sink = local;
}

// 2) Very hard random branch
void test_random(long iters) {
    volatile int local = 0;
    uint32_t state = 1u;

    for (long i = 0; i < iters; i++) {
        uint32_t r = xorshift32(&state);
        if (r & 1u) {
            local++;
        } else {
            local--;
        }
    }

    sink = local;
}

// 3) Biased branch (90% taken)
void test_biased(long iters) {
    volatile int local = 0;
    uint32_t state = 1u;

    for (long i = 0; i < iters; i++) {
        uint32_t r = xorshift32(&state);
        if ((r & 0x7u) != 0) {
            local++;
        } else {
            local--;
        }
    }

    sink = local;
}

// Indirect call targets.
__attribute__((noinline))
void target_A(int x) {
    sink += x;
}

__attribute__((noinline))
void target_B(int x) {
    sink -= x;
}

// 4) Predictable indirect branch
void test_indirect_const(long iters) {
    void (*fp)(int) = target_A;

    for (long i = 0; i < iters; i++) {
        fp((int)i);   // same target every time
    }
}

// 5) Hard indirect branch: choose target A or B randomly each time.
void test_indirect_random(long iters) {
    uint32_t state = 1u;

    for (long i = 0; i < iters; i++) {
        uint32_t r = xorshift32(&state);
        void (*fp)(int) = (r & 1u) ? target_A : target_B;
        fp((int)i);
    }
}

// Main harness
int main(int argc, char **argv) {
    if (argc < 3) {
        fprintf(stderr,
            "Usage: %s MODE <iterations>\n"
            "MODE = predictable | random | biased | indirect_const | indirect_random\n",
            argv[0]);
        return 1;
    }

    const char *mode = argv[1];
    long iters = atol(argv[2]);
    if (iters <= 0) {
        fprintf(stderr, "Iterations must be > 0\n");
        return 1;
    }

    for (int i = 0; i < 100000; i++) {
        sink++;
    }

    if (mode[0] == 'p') {
        test_predictable(iters);
    } else if (mode[0] == 'r' && mode[1] == 'a') {
        test_random(iters);
    } else if (mode[0] == 'b') {
        test_biased(iters);
    } else if (mode[0] == 'i' && mode[9] == 'c') {
        test_indirect_const(iters);
    } else if (mode[0] == 'i' && mode[9] == 'r') {
        test_indirect_random(iters);
    } else {
        fprintf(stderr, "Unknown mode '%s'\n", mode);
        return 1;
    }

    printf("Done: mode=%s, iters=%ld, sink=%d\n", mode, sink);
    return 0;
}
