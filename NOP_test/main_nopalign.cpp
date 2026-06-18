#include <cstdint>
#include <cstdio>

extern "C" void aligned_site_k28();
extern "C" void aligned_site_k20();
extern "C" void aligned_site_k12();
extern "C" void aligned_site_k8();

static inline uintptr_t addr_of(void (*fn)()) {
  return reinterpret_cast<uintptr_t>(fn);
}

static void report(const char* name, void (*fn)(), int k) {
  auto a = addr_of(fn);
  uintptr_t mask = (1ULL << k) - 1ULL;
  std::printf("%s @ 0x%016lx, low %d bits zero? %d\n",
              name, (unsigned long)a, k, (int)((a & mask) == 0));
}

int main() {
  report("aligned_site_k8 ",  aligned_site_k8,  8);
  report("aligned_site_k12",  aligned_site_k12, 12);
  report("aligned_site_k20",  aligned_site_k20, 20);
  report("aligned_site_k28", aligned_site_k28, 28);
  // execute them (also keeps them from being removed in weird LTO cases)

  aligned_site_k8();
  aligned_site_k12();
  aligned_site_k20();
  aligned_site_k28();

  return 0;
}
