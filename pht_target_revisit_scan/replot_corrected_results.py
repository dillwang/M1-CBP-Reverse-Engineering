#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


def make_heatmap(df: pd.DataFrame, out_png: Path, title: str) -> None:
    align_values = sorted(df["align_bits"].unique())
    jump_values = sorted(df["dummy_branches_corrected"].unique())

    pivot = (
        df.pivot(index="align_bits", columns="dummy_branches_corrected", values="mispred_per_iter")
        .reindex(index=align_values, columns=jump_values)
    )

    arr = pivot.to_numpy(dtype=float)

    fig, ax = plt.subplots(figsize=(16, 9))
    im = ax.imshow(arr, aspect="auto", origin="upper")

    ax.set_title(title)
    ax.set_xlabel("Dummy branches")
    ax.set_ylabel("Shared .p2align bits")

    ax.set_xticks(np.arange(len(jump_values)))
    ax.set_xticklabels(jump_values, rotation=90)

    ax.set_yticks(np.arange(len(align_values)))
    ax.set_yticklabels(align_values)

    ax.set_xticks(np.arange(-0.5, len(jump_values), 1), minor=True)
    ax.set_yticks(np.arange(-0.5, len(align_values), 1), minor=True)
    ax.grid(which="minor", linewidth=0.8)
    ax.tick_params(which="minor", bottom=False, left=False)

    cbar = plt.colorbar(im, ax=ax)
    cbar.set_label("mispredictions per iteration")

    plt.tight_layout()
    plt.savefig(out_png, dpi=200)
    plt.close(fig)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("input_csv", help="Path to original results.csv")
    parser.add_argument("--base-rc5", type=float, default=150000.0)
    parser.add_argument("--iters", type=float, default=100000.0)
    parser.add_argument("--out-csv", default=None, help="Output corrected CSV path")
    parser.add_argument("--out-png", default=None, help="Output corrected heatmap path")
    args = parser.parse_args()

    input_csv = Path(args.input_csv).resolve()
    if not input_csv.exists():
        raise FileNotFoundError(f"Input CSV not found: {input_csv}")

    out_csv = Path(args.out_csv).resolve() if args.out_csv else input_csv.with_name("corrected_results.csv")
    out_png = Path(args.out_png).resolve() if args.out_png else input_csv.with_name("corrected_heatmap.png")

    df = pd.read_csv(input_csv)

    required_cols = {"align_bits", "num_jumps", "rc5"}
    missing = required_cols - set(df.columns)
    if missing:
        raise ValueError(f"Input CSV missing required columns: {sorted(missing)}")

    df["dummy_branches_corrected"] = df["num_jumps"] + 2
    df["mispred_per_iter"] = (df["rc5"] - args.base_rc5) / args.iters

    preferred = [
        "align_bits",
        "num_jumps",
        "dummy_branches_corrected",
        "rc5",
        "mispred_per_iter",
    ]
    remaining = [c for c in df.columns if c not in preferred]
    df = df[preferred + remaining]

    df.to_csv(out_csv, index=False)

    title = f"Corrected heatmap | mispred_per_iter = (rc5 - {int(args.base_rc5)}) / {int(args.iters)}"
    make_heatmap(df, out_png, title)

    print(f"Wrote corrected CSV: {out_csv}")
    print(f"Wrote corrected heatmap: {out_png}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
