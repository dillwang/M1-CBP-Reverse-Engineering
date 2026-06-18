#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <Amin> <Amax>"
  exit 2
fi

AMIN="$1"
AMAX="$2"

CC=gcc
CFLAGS="-O2 -fno-omit-frame-pointer"
LDFLAGS=""
EVT_INSERT_AFTER=".eh_frame"

for A in $(seq "$AMIN" "$AMAX"); do
  DELTA_HEX=$(python3 - <<EOF
A=int("$A")
print(hex(1<<A))
EOF
)

  OUT="firestorm_pht_align_a${A}"
  echo "[build] A=${A} delta=${DELTA_HEX} -> ${OUT}"

  cat > link.ld <<EOF
SECTIONS
{
  . = ALIGN(0x1000);

  /* Place TB1 at an address with low A bits zero */
  . = ALIGN(${DELTA_HEX});
  .tb1 : { KEEP(*(.tb1)) }

  /* Place TB2 exactly 2^A bytes after TB1 */
  . = ADDR(.tb1) + ${DELTA_HEX};
  .tb2 : { KEEP(*(.tb2)) }
}
INSERT AFTER ${EVT_INSERT_AFTER};
EOF

  $CC $CFLAGS tb.c tb.S -Wl,-T,link.ld -o "$OUT"
done
