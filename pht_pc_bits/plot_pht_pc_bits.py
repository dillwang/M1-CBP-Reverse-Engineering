#!/usr/bin/env python3
"""
Plot manually collected pht_pc_bits data.

Expected CSV columns:
    A,dummyN,iters,seed,rc5,notes

Only A and rc5 are required. If the CSV has no iters column, pass --iters.

Examples:
    python3 plot_pht_pc_bits.py pht_pc_bits_points.csv --outdir plots
    python3 plot_pht_pc_bits.py pht_pc_bits_points.csv --iters 2000000 --baseline auto --outdir plots
    python3 plot_pht_pc_bits.py --make-template pht_pc_bits_points_template.csv
"""

from __future__ import annotations

import argparse
import csv
from pathlib import Path
from typing import Iterable

import matplotlib.pyplot as plt
import pandas as pd


A_ALIASES = ("A", "a", "align", "align_bits", "pc_bit", "bit", "delta_bit")
RC5_ALIASES = ("rc5", "RC5", "count", "counts", "mispred", "mispreds", "mispredictions")
ITERS_ALIASES = ("iters", "iterations", "iter", "loop_iters")
GROUP_ALIASES = ("dummyN", "dummy_n", "dummy", "dummy_links", "seed", "label", "series")


def first_existing(columns: Iterable[str], aliases: Iterable[str]) -> str | None:
    cols = list(columns)
    lower_to_original = {c.lower(): c for c in cols}
    for alias in aliases:
        if alias in cols:
            return alias
        if alias.lower() in lower_to_original:
            return lower_to_original[alias.lower()]
    return None


def clean_count(value) -> float:
    """Convert perf-style strings like '1,234,567' or '1.234.567' to float."""
    if pd.isna(value):
        raise ValueError("missing count")
    text = str(value).strip()
    if not text:
        raise ValueError("empty count")
    text = text.replace(",", "")
    # perf on some locales may use periods as thousands separators.
    if text.count(".") > 1:
        text = text.replace(".", "")
    return float(text)


def load_data(csv_path: Path, default_iters: float | None) -> pd.DataFrame:
    df = pd.read_csv(csv_path)

    a_col = first_existing(df.columns, A_ALIASES)
    rc5_col = first_existing(df.columns, RC5_ALIASES)
    iters_col = first_existing(df.columns, ITERS_ALIASES)

    if a_col is None:
        raise ValueError(f"Could not find PC-bit column. Accepted names: {A_ALIASES}")
    if rc5_col is None:
        raise ValueError(f"Could not find rc5/count column. Accepted names: {RC5_ALIASES}")

    out = pd.DataFrame()
    out["A"] = pd.to_numeric(df[a_col], errors="coerce")
    out["rc5"] = df[rc5_col].map(clean_count)

    if iters_col is not None:
        out["iters"] = pd.to_numeric(df[iters_col], errors="coerce")
    elif default_iters is not None:
        out["iters"] = float(default_iters)
    else:
        raise ValueError("No iters column found. Pass --iters <N> or add an iters column to the CSV.")

    for col in df.columns:
        if col not in (a_col, rc5_col, iters_col):
            out[col] = df[col]

    out = out.dropna(subset=["A", "rc5", "iters"]).copy()
    out["A"] = out["A"].astype(int)
    out["rc5_per_iter"] = out["rc5"] / out["iters"]
    return out.sort_values(["A"]).reset_index(drop=True)


def resolve_baseline(df: pd.DataFrame, baseline: str | None) -> float | None:
    if baseline is None or baseline.lower() == "none":
        return None
    if baseline.lower() == "auto":
        return float(df["rc5"].min())
    if baseline.lower() == "median":
        return float(df["rc5"].median())
    return float(baseline)


def choose_group_col(df: pd.DataFrame, requested: str | None) -> str | None:
    if requested:
        if requested not in df.columns:
            raise ValueError(f"Requested group column not found: {requested}")
        return requested
    for col in GROUP_ALIASES:
        if col in df.columns and df[col].nunique(dropna=True) > 1:
            return col
    return None


def plot_series(df: pd.DataFrame, y_col: str, ylabel: str, title: str, out_png: Path, group_col: str | None) -> None:
    fig, ax = plt.subplots(figsize=(10, 5.5))

    if group_col:
        for group_value, group_df in df.groupby(group_col, dropna=False):
            group_df = group_df.sort_values("A")
            ax.plot(group_df["A"], group_df[y_col], marker="o", label=f"{group_col}={group_value}")
        ax.legend()
    else:
        ax.plot(df["A"], df[y_col], marker="o")

    ax.set_title(title)
    ax.set_xlabel("PC separation bit A in 2^A bytes")
    ax.set_ylabel(ylabel)
    ax.grid(True)
    ax.set_xticks(sorted(df["A"].unique()))
    plt.tight_layout()
    fig.savefig(out_png, dpi=200)
    plt.close(fig)


def write_template(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["A", "dummyN", "iters", "seed", "rc5", "notes"])
        writer.writeheader()
        for a in range(4, 21):
            writer.writerow({"A": a, "dummyN": 98, "iters": 2000000, "seed": 1, "rc5": "", "notes": ""})
    print(f"Wrote template CSV: {path}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Plot pht_pc_bits manual rc5 measurements.")
    parser.add_argument("input_csv", nargs="?", help="CSV containing A and rc5 columns.")
    parser.add_argument("--iters", type=float, default=None, help="Iteration count if CSV has no iters column.")
    parser.add_argument("--baseline", default=None, help="none, auto, median, or a numeric raw rc5 baseline.")
    parser.add_argument("--group-col", default=None, help="Optional column used to split multiple plotted series.")
    parser.add_argument("--outdir", default="plots", help="Output directory.")
    parser.add_argument("--top-n", type=int, default=10, help="Rows to write to top-positions CSV.")
    parser.add_argument("--make-template", default=None, help="Write a fill-in CSV template and exit.")
    args = parser.parse_args()

    if args.make_template:
        write_template(Path(args.make_template))
        return 0

    if not args.input_csv:
        parser.error("input_csv is required unless --make-template is used")

    csv_path = Path(args.input_csv)
    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    df = load_data(csv_path, args.iters)
    baseline = resolve_baseline(df, args.baseline)

    if baseline is not None:
        df["baseline_rc5"] = baseline
        df["excess_rc5"] = df["rc5"] - baseline
        df["excess_rc5_per_iter"] = df["excess_rc5"] / df["iters"]

    group_col = choose_group_col(df, args.group_col)

    normalized_csv = outdir / "pht_pc_bits_normalized.csv"
    df.to_csv(normalized_csv, index=False)

    plot_series(
        df,
        y_col="rc5_per_iter",
        ylabel="rc5 / iteration",
        title="PHT PC-bit alignment sweep",
        out_png=outdir / "pht_pc_bits_rc5_per_iter.png",
        group_col=group_col,
    )

    if baseline is not None:
        plot_series(
            df,
            y_col="excess_rc5_per_iter",
            ylabel="excess rc5 / iteration",
            title=f"PHT PC-bit alignment sweep, baseline={baseline:g}",
            out_png=outdir / "pht_pc_bits_excess_per_iter.png",
            group_col=group_col,
        )
        sort_col = "excess_rc5_per_iter"
    else:
        sort_col = "rc5_per_iter"

    top_csv = outdir / "pht_pc_bits_top_positions.csv"
    df.sort_values(sort_col, ascending=False).head(args.top_n).to_csv(top_csv, index=False)

    print(f"Wrote normalized CSV: {normalized_csv}")
    print(f"Wrote main plot:      {outdir / 'pht_pc_bits_rc5_per_iter.png'}")
    if baseline is not None:
        print(f"Wrote excess plot:    {outdir / 'pht_pc_bits_excess_per_iter.png'}")
    print(f"Wrote top positions:  {top_csv}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
