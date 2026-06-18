#include <cstdint>
#include <cstdio>

extern "C" void site_A();
extern "C" void site_B();

static inline uintptr_t addr_of(void (*fn)()) {
  return reinterpret_cast<uintptr_t>(fn);
}

int main() {
  auto a = addr_of(site_A);
  auto b = addr_of(site_B);

  std::printf("site_A = 0x%016lx\n", (unsigned long)a);
  std::printf("site_B = 0x%016lx\n", (unsigned long)b);
  std::printf("diff   = 0x%016lx\n", (unsigned long)(b - a));

  site_A();
  site_B();

  bool low32_a = ((a & 0xffffffffULL) == 0);
  bool low32_b = ((b & 0xffffffffULL) == 0);
  bool diff4g  = ((b - a) == (1ULL << 32));

  std::printf("low32(A)=0? %d, low32(B)=0? %d, diff==4GB? %d\n",
              (int)low32_a, (int)low32_b, (int)diff4g);

  return (low32_a && low32_b && diff4g) ? 0 : 1;
}
