// tb.c — Firestorm differential PHR footprint test (scan PC toggle bits 2..10)
//
// Build:
//   gcc -O2 tb.c tb.S -o firestorm_phr_tb
//
// Run example:
//   taskset -c 4 perf stat -e apple_firestorm_pmu/<mispred_evt>/ \
//     ./firestorm_phr_tb 10 80 2000000 0x12345678
//
// Args:
//   bit    : toggle PC bit (2..20)
//   ndummy : number of unconditional dummy branches between injection and probe (0..MAX_DUMMY)
//   iters  : iterations (default 2,000,000)
//   seed   : RNG seed (default 0x12345678)

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifndef MAX_DUMMY
#define MAX_DUMMY 160
#endif

// externs from tb.S
extern void run_inject_bit2 (uint64_t iters, uint32_t seed, uint32_t ndummy);
extern void run_inject_bit3 (uint64_t iters, uint32_t seed, uint32_t ndummy);
extern void run_inject_bit4 (uint64_t iters, uint32_t seed, uint32_t ndummy);
extern void run_inject_bit5 (uint64_t iters, uint32_t seed, uint32_t ndummy);
extern void run_inject_bit6 (uint64_t iters, uint32_t seed, uint32_t ndummy);
extern void run_inject_bit7 (uint64_t iters, uint32_t seed, uint32_t ndummy);
extern void run_inject_bit8 (uint64_t iters, uint32_t seed, uint32_t ndummy);
extern void run_inject_bit9 (uint64_t iters, uint32_t seed, uint32_t ndummy);
extern void run_inject_bit10(uint64_t iters, uint32_t seed, uint32_t ndummy);
extern void run_inject_bit11 (uint64_t iters, uint32_t seed, uint32_t ndummy);
extern void run_inject_bit12 (uint64_t iters, uint32_t seed, uint32_t ndummy);
extern void run_inject_bit13 (uint64_t iters, uint32_t seed, uint32_t ndummy);
extern void run_inject_bit14 (uint64_t iters, uint32_t seed, uint32_t ndummy);
extern void run_inject_bit15 (uint64_t iters, uint32_t seed, uint32_t ndummy);
extern void run_inject_bit16 (uint64_t iters, uint32_t seed, uint32_t ndummy);
extern void run_inject_bit17 (uint64_t iters, uint32_t seed, uint32_t ndummy);
extern void run_inject_bit18 (uint64_t iters, uint32_t seed, uint32_t ndummy);

static void usage(const char *p) {
  fprintf(stderr,
    "Usage: %s <bit(2..20)> <ndummy(0..%d)> [iters] [seed]\n"
    "Example: %s 10 80 2000000 0x12345678\n",
    p, MAX_DUMMY, p);
}

int main(int argc, char **argv) {
  if (argc < 3) { usage(argv[0]); return 1; }

  int bit = atoi(argv[1]);
  long nd = strtol(argv[2], NULL, 0);
  if (nd < 0 || nd > MAX_DUMMY) {
    fprintf(stderr, "ndummy out of range (0..%d)\n", MAX_DUMMY);
    return 1;
  }

  uint64_t iters = (argc >= 4) ? strtoull(argv[3], NULL, 0) : 2000000ULL;
  uint32_t seed  = (argc >= 5) ? (uint32_t)strtoul(argv[4], NULL, 0) : 0x12345678u;

  switch (bit) {
    case 2:  run_inject_bit2(iters, seed, (uint32_t)nd); break;
    case 3:  run_inject_bit3(iters, seed, (uint32_t)nd); break;
    case 4:  run_inject_bit4(iters, seed, (uint32_t)nd); break;
    case 5:  run_inject_bit5(iters, seed, (uint32_t)nd); break;
    case 6:  run_inject_bit6(iters, seed, (uint32_t)nd); break;
    case 7:  run_inject_bit7(iters, seed, (uint32_t)nd); break;
    case 8:  run_inject_bit8(iters, seed, (uint32_t)nd); break;
    case 9:  run_inject_bit9(iters, seed, (uint32_t)nd); break;
    case 10: run_inject_bit10(iters, seed, (uint32_t)nd); break;
    case 11: run_inject_bit11(iters, seed, (uint32_t)nd); break;
    case 12: run_inject_bit12(iters, seed, (uint32_t)nd); break;
    case 13: run_inject_bit13(iters, seed, (uint32_t)nd); break;
    case 14: run_inject_bit14(iters, seed, (uint32_t)nd); break;
    case 15: run_inject_bit15(iters, seed, (uint32_t)nd); break;
    case 16: run_inject_bit16(iters, seed, (uint32_t)nd); break;
    case 17: run_inject_bit17(iters, seed, (uint32_t)nd); break;
    case 18: run_inject_bit18(iters, seed, (uint32_t)nd); break;

    default:
      fprintf(stderr, "bit must be 2..20\n");
      usage(argv[0]);
      return 1;
  }

  return 0;
}
