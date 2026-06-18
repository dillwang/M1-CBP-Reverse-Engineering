#!/usr/bin/env python3
"""
Plot Firestorm target-bit heatmap from a sweep CSV (no pandas).

Expected CSV columns (header must include these):
  bit, ndummy, iters, rc5, miss_per_iter
Optional:
  ndummy_effective (if present we will use it, else ndummy+2)

Example:
  python3 plot_target_heatmap_from_csv.py \
    --csv results.csv \
    --out firestorm_target_heatmap \
    --dummy-overhead 2 \
    --bit-min 2 --bit-max 31
"""

from __future__ import annotations

import argparse
import csv
import os
from dataclasses import dataclass
from typing import Dict, List, Optional, Tuple

import numpy as np
import matplotlib.pyplot as plt


def ensure_dir_for(path: str) -> None:
    d = os.path.dirname(os.path.abspath(path))
    if d and not os.path.exists(d):
        os.makedirs(d, exist_ok=True)


@dataclass
class Row:
    bit: int
    ndummy: int
    ndummy_eff: int
    iters: int
    rc5: int
    miss_per_iter: float


def load_rows(path: str, dummy_overhead: int) -> List[Row]:
    rows: List[Row] = []
    with open(path, "r", newline="") as f:
        r = csv.DictReader(f)
        hdr = [h.strip().lower() for h in (r.fieldnames or [])]
        # map lowercase header -> original key
        keymap = {h.strip().lower(): h for h in (r.fieldnames or [])}

        need = ["bit", "ndummy"]
        for k in need:
            if k not in hdr:
                raise SystemExit(f"CSV missing required column '{k}'. Header={r.fieldnames}")

        has_eff = "ndummy_effective" in hdr
        has_mpi = "miss_per_iter" in hdr
        has_rc5 = "rc5" in hdr
        has_iters = "iters" in hdr

        if not has_mpi:
            if not (has_rc5 and has_iters):
                raise SystemExit("CSV must contain 'miss_per_iter' OR both 'rc5' and 'iters'.")

        for line in r:
            bit = int(line[keymap["bit"]])
            nd = int(line[keymap["ndummy"]])

            if has_eff:
                nde = int(line[keymap["ndummy_effective"]])
            else:
                nde = nd + dummy_overhead

            iters = int(line[keymap["iters"]]) if has_iters else 0
            rc5 = int(line[keymap["rc5"]]) if has_rc5 else 0

            if has_mpi:
                mpi = float(line[keymap["miss_per_iter"]])
            else:
                mpi = (float(rc5) / float(iters)) if iters > 0 else float("nan")

            rows.append(Row(bit=bit, ndummy=nd, ndummy_eff=nde, iters=iters, rc5=rc5, miss_per_iter=mpi))
    return rows


def plot_heatmap(
    out_png: str,
    bits: List[int],
    dummies_eff: List[int],
    grid: np.ndarray,
    title: str,
    y_label: str,
) -> None:
    ensure_dir_for(out_png)

    fig, ax = plt.subplots(figsize=(13.5, 8.0), dpi=150)

    im = ax.imshow(
        grid,
        aspect="auto",
        interpolation="nearest",
        origin="upper",
    )

    ax.set_title(title, pad=10)
    ax.set_xlabel("Dummy branches")
    ax.set_ylabel(y_label)

    ax.set_xticks(np.arange(len(dummies_eff)))
    ax.set_xticklabels([str(d) for d in dummies_eff], rotation=90)

    ax.set_yticks(np.arange(len(bits)))
    ax.set_yticklabels([str(b) for b in bits])

    # Gridlines (same style as your working script)
    ax.set_xticks(np.arange(-0.5, len(dummies_eff), 1), minor=True)
    ax.set_yticks(np.arange(-0.5, len(bits), 1), minor=True)
    ax.grid(which="minor", linestyle="-", linewidth=0.8)
    ax.tick_params(which="minor", bottom=False, left=False)

    cbar = fig.colorbar(im, ax=ax, fraction=0.03, pad=0.02)
    cbar.set_label("rc5 / iter", rotation=270, labelpad=15)

    fig.tight_layout()
    fig.savefig(out_png)
    plt.close(fig)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--csv", default="firestorm_heat.csv", help="Sweep CSV file")
    ap.add_argument("--out", default="firestorm_target_heatmap", help="Output prefix (png)")
    ap.add_argument("--dummy-overhead", type=int, default=2, help="Add this to ndummy if ndummy_effective column missing")
    ap.add_argument("--bit-min", type=int, default=2)
    ap.add_argument("--bit-max", type=int, default=31)
    ap.add_argument("--dummy-min", type=int, default=None)
    ap.add_argument("--dummy-max", type=int, default=None)
    ap.add_argument("--ylabel", default="Target toggle bit")
    args = ap.parse_args()

    rows = load_rows(args.csv, args.dummy_overhead)

    # Filter to requested ranges
    rows = [r for r in rows if args.bit_min <= r.bit <= args.bit_max]
    if args.dummy_min is not None:
        rows = [r for r in rows if r.ndummy_eff >= args.dummy_min]
    if args.dummy_max is not None:
        rows = [r for r in rows if r.ndummy_eff <= args.dummy_max]

    if not rows:
        raise SystemExit("No rows after filtering. Check bit/dummy ranges.")

    bits = sorted(set(r.bit for r in rows))
    dums = sorted(set(r.ndummy_eff for r in rows))

    bit_to_i = {b: i for i, b in enumerate(bits)}
    dum_to_j = {d: j for j, d in enumerate(dums)}

    grid = np.full((len(bits), len(dums)), np.nan, dtype=float)

    # If multiple measurements for same cell, average them
    acc: Dict[Tuple[int, int], List[float]] = {}
    for r in rows:
        i = bit_to_i[r.bit]
        j = dum_to_j[r.ndummy_eff]
        acc.setdefault((i, j), []).append(r.miss_per_iter)

    for (i, j), vals in acc.items():
        grid[i, j] = float(np.mean(vals))

    out_png = args.out + ".png"
    title = f"Firestorm target-bit sweep (from CSV) | bits={bits[0]}..{bits[-1]}"

    plot_heatmap(out_png, bits, dums, grid, title, args.ylabel)

    print(f"Wrote: {out_png}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
