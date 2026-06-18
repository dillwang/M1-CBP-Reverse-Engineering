#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./build_bits.sh 2 16
# builds firestorm_target_ld_b2 ... firestorm_target_ld_b16

B_LO="${1:-2}"
B_HI="${2:-16}"

# With INSERT scripts, PIE is usually fine, but non-PIE is still simpler to reason about.
# CFLAGS="-O2 -fno-pie"
# LDFLAGS="-no-pie"
# CFLAGS="-O0 -g -fno-omit-frame-pointer -fno-pie"
# LDFLAGS="-no-pie"
CFLAGS="-O2 -fno-pie -fno-asynchronous-unwind-tables -fno-unwind-tables"
LDFLAGS="-no-pie -Wl,--no-eh-frame-hdr"


for ((b=B_LO; b<=B_HI; b++)); do
  delta=$((1 << b))
  delta_hex=$(printf "0x%x" "${delta}")

  # IMPORTANT: This is a script *fragment* that keeps the default PHDR/LOAD layout.
  cat > link.ld <<EOF
SECTIONS
{
  /* Place tgt0 on a page boundary to make low-bit deltas meaningful and predictable */
  . = ALIGN(0x1000);
  .tgt0 : { KEEP(*(.tgt0)) }

  /* Place tgt1 exactly DELTA bytes after tgt0 */
  . = ADDR(.tgt0) + ${delta_hex};
  .tgt1 : { KEEP(*(.tgt1)) }
}
INSERT AFTER .text;
EOF

  out="firestorm_target_ld_b${b}"
  echo "[build] bit=${b} delta=${delta_hex} -> ${out}"

  gcc ${CFLAGS} tb.c tb.S targets.S -Wl,-T,link.ld ${LDFLAGS} -o "${out}"
done

echo "Done."
