// phr_tb.c
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

extern volatile uint32_t global_sink;
volatile uint32_t global_sink = 0;

void phr_test(uint64_t num_tries, uint64_t dummy_count);

static uint64_t parse_u64(const char *s) {
    char *end = 0;
    unsigned long long v = strtoull(s, &end, 0);
    if (!s[0] || (end && *end)) {
        fprintf(stderr, "Bad integer: %s\n", s);
        exit(1);
    }
    return (uint64_t)v;
}

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <tries> <dummy_count>\n", argv[0]);
        fprintf(stderr, "Example: %s 20000000 100\n", argv[0]);
        return 1;
    }

    uint64_t tries = parse_u64(argv[1]);
    uint64_t dummy = parse_u64(argv[2]);

    phr_test(tries, dummy);

    printf("Done: tries=%llu dummy=%llu sink=%u\n",
           (unsigned long long)tries,
           (unsigned long long)dummy,
           global_sink);
    return 0;
}
