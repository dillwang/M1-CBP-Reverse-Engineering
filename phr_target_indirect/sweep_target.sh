#!/usr/bin/env bash
set -euo pipefail

EVT="apple_firestorm_pmu/rc5/"
CORE=4
ITERS=2000000
SEED=1

# Sweep ranges (edit as you like)
B_LO=2
B_HI=31

N_LO=65
N_HI=100
N_STEP=1

DUMMY_OVERHEAD=2

OUT="results.csv"
echo "bit,ndummy,ndummy_effective,iters,rc5,miss_per_iter,seconds" > "$OUT"

export LC_ALL=C

for b in $(seq $B_LO $B_HI); do
  bin="./firestorm_target_ld_b${b}"
  if [[ ! -x "$bin" ]]; then
    echo "Missing binary: $bin" >&2
    exit 1
  fi

  for n in $(seq $N_LO $N_STEP $N_HI); do
    perf_out=$(
      taskset -c "$CORE" perf stat -x, -e "$EVT" "$bin" "$n" "$ITERS" "$SEED" \
        2>&1 1>/dev/null
    )

    rc5=$(echo "$perf_out" | awk -F, -v e="$EVT" '
      $3==e {
        gsub(/ /,"",$1);
        gsub(/,/,"",$1);  # just in case
        print $1;
        exit
      }')


    sec=$(echo "$perf_out" | awk -F, '
      /seconds time elapsed/ {
        gsub(/ /,"",$1);
        print $1;
        exit
      }')

    if [[ -z "${sec:-}" ]]; then sec=""; fi

    mpi=$(awk -v c="$rc5" -v it="$ITERS" 'BEGIN{ if(it>0) printf "%.9f", c/it; else print "nan"; }')

    neff=$((n + DUMMY_OVERHEAD))

    if [[ -z "${rc5:-}" ]]; then
      echo "Failed to parse rc5 at bit=$b ndummy=$n" >&2
      echo "---- perf output ----" >&2
      echo "$perf_out" >&2
      exit 1
    fi

    echo "$b,$n,$neff,$ITERS,$rc5,$mpi,$sec" >> "$OUT"
  done
done

echo "Wrote $OUT"
