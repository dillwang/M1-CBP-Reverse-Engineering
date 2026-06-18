// tb.c — driver for linker-script placed targets L0/L1
// Build is done by the generator script (build_bits.sh)
//
// Runtime usage (per-bit binary):
//   ./firestorm_target_ld_b16 <ndummy> <iters> [seed]
//
// Example perf:
//   taskset -c 4 perf stat -e apple_firestorm_pmu/rc5/ ./firestorm_target_ld_b16 100 2000000

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifndef MAX_DUMMY
#define MAX_DUMMY 160
#endif

volatile uint64_t global_sink = 0;

extern void run_target_ld(uint64_t iters, uint32_t seed, uint32_t ndummy);

static void usage(const char *p) {
  fprintf(stderr, "Usage: %s <ndummy(0..%d)> <iters> [seed]\n", p, MAX_DUMMY);
}

int main(int argc, char **argv) {
  if (argc < 3) { usage(argv[0]); return 1; }

  long nd = strtol(argv[1], NULL, 0);
  if (nd < 0 || nd > MAX_DUMMY) {
    fprintf(stderr, "ndummy out of range (0..%d)\n", MAX_DUMMY);
    return 1;
  }

  uint64_t iters = strtoull(argv[2], NULL, 0);
  uint32_t seed  = (argc >= 4) ? (uint32_t)strtoul(argv[3], NULL, 0) : 1u;

  run_target_ld(iters, seed, (uint32_t)nd);

  // Prevent “dead code” arguments paranoia; also prints something stable.
  printf("Done: sink=%llu\n", (unsigned long long)global_sink);
  return 0;
}
