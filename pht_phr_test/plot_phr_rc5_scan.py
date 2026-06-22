#!/usr/bin/env python3

from __future__ import annotations

import argparse
import csv
import math
from pathlib import Path
from statistics import median
from typing import Iterable

import matplotlib.pyplot as plt


DEFAULT_ITERS = 1_000_000


def parse_count(value: str | int | float) -> float:
    if isinstance(value, (int, float)):
        return float(value)
    cleaned = str(value).strip().replace(",", "")
    if cleaned in {"", "<not counted>", "<not supported>"}:
        raise ValueError(f"Invalid perf count: {value!r}")
    return float(cleaned)


def read_scan_csv(path: Path) -> list[dict[str, float]]:
    with path.open(newline="") as f:
        reader = csv.DictReader(f)
        required = {"test_pos", "rc5"}
        missing = required - set(reader.fieldnames or [])
        if missing:
            raise ValueError(f"Input CSV missing required columns: {sorted(missing)}")

        rows: list[dict[str, float]] = []
        for line_no, row in enumerate(reader, start=2):
            try:
                rows.append(
                    {
                        "test_pos": int(row["test_pos"]),
                        "rc5": parse_count(row["rc5"]),
                    }
                )
            except Exception as exc:  # noqa: BLE001 - include row context for debugging
                raise ValueError(f"Could not parse row {line_no}: {row}") from exc

    if not rows:
        raise ValueError(f"Input CSV has no rows: {path}")

    rows.sort(key=lambda r: int(r["test_pos"]))
    return rows


def baseline_from_low_percentile(values: Iterable[float], percentile: float) -> float:
    values_sorted = sorted(float(v) for v in values)
    if not values_sorted:
        raise ValueError("No values available for baseline calculation")
    if not (0 < percentile <= 100):
        raise ValueError("--baseline-percentile must be in the range (0, 100]")

    n = max(1, math.ceil(len(values_sorted) * percentile / 100.0))
    return float(median(values_sorted[:n]))


def add_derived_columns(
    rows: list[dict[str, float]],
    loop_iters: int,
    baseline_rc5: float,
) -> list[dict[str, float]]:
    out: list[dict[str, float]] = []
    for row in rows:
        rc5 = float(row["rc5"])
        out.append(
            {
                "test_pos": int(row["test_pos"]),
                "rc5": rc5,
                "rc5_per_iter": rc5 / float(loop_iters),
                "excess_rc5": rc5 - baseline_rc5,
                "excess_per_iter": (rc5 - baseline_rc5) / float(loop_iters),
            }
        )
    return out


def write_csv(path: Path, rows: list[dict[str, float]]) -> None:
    if not rows:
        raise ValueError("No rows to write")
    with path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


def annotate_top_points(ax, rows: list[dict[str, float]], y_key: str, top_n: int) -> None:
    if top_n <= 0:
        return
    for row in sorted(rows, key=lambda r: float(r[y_key]), reverse=True)[:top_n]:
        x = int(row["test_pos"])
        y = float(row[y_key])
        ax.annotate(str(x), xy=(x, y), xytext=(0, 5), textcoords="offset points", ha="center", fontsize=8)


def plot_rc5_per_iter(
    rows: list[dict[str, float]],
    out_png: Path,
    title: str,
    top_n: int,
) -> None:
    x = [int(r["test_pos"]) for r in rows]
    y = [float(r["rc5_per_iter"]) for r in rows]

    fig, ax = plt.subplots(figsize=(14, 6))
    ax.plot(x, y, marker="o", linewidth=1)
    ax.set_title(title)
    ax.set_xlabel("Test PHR injection position")
    ax.set_ylabel("rc5 / iteration")
    ax.grid(True, linewidth=0.6)
    annotate_top_points(ax, rows, "rc5_per_iter", top_n)
    fig.tight_layout()
    fig.savefig(out_png, dpi=200)
    plt.close(fig)


def plot_excess_per_iter(
    rows: list[dict[str, float]],
    out_png: Path,
    title: str,
    baseline_rc5: float,
    loop_iters: int,
    top_n: int,
) -> None:
    x = [int(r["test_pos"]) for r in rows]
    y = [float(r["excess_per_iter"]) for r in rows]

    fig, ax = plt.subplots(figsize=(14, 6))
    ax.bar(x, y)
    ax.axhline(0.0, linewidth=1)
    ax.set_title(title)
    ax.set_xlabel("Test PHR injection position")
    ax.set_ylabel("excess rc5 / iteration")
    ax.grid(True, axis="y", linewidth=0.6)
    annotate_top_points(ax, rows, "excess_per_iter", top_n)

    note = f"baseline_rc5={baseline_rc5:.0f}; loop_iters={loop_iters}"
    ax.text(0.99, 0.97, note, transform=ax.transAxes, ha="right", va="top", fontsize=9)

    fig.tight_layout()
    fig.savefig(out_png, dpi=200)
    plt.close(fig)


def main() -> int:
    parser = argparse.ArgumentParser(description="Plot phr_rc5_scan.csv from the PHR-position scan.")
    parser.add_argument("input_csv", nargs="?", default="phr_rc5_scan.csv", help="Input scan CSV")
    parser.add_argument("--iters", type=int, default=DEFAULT_ITERS, help="Loop iterations used by the benchmark")
    parser.add_argument("--outdir", default=None, help="Output directory; default: <input_csv directory>/plots")
    parser.add_argument("--prefix", default=None, help="Output filename prefix; default: input CSV stem")
    parser.add_argument("--baseline-rc5", type=float, default=None, help="Manual baseline rc5 count")
    parser.add_argument(
        "--baseline-percentile",
        type=float,
        default=10.0,
        help="When --baseline-rc5 is absent, use median of the lowest N percent of rc5 values",
    )
    parser.add_argument("--top-n", type=int, default=8, help="Annotate and export the top N highest-rc5 positions")
    parser.add_argument("--title", default=None, help="Optional plot title prefix")
    args = parser.parse_args()

    input_csv = Path(args.input_csv).resolve()
    if not input_csv.exists():
        raise FileNotFoundError(f"Input CSV not found: {input_csv}")
    if args.iters <= 0:
        raise ValueError("--iters must be positive")

    rows = read_scan_csv(input_csv)
    rc5_values = [float(r["rc5"]) for r in rows]
    baseline_rc5 = (
        float(args.baseline_rc5)
        if args.baseline_rc5 is not None
        else baseline_from_low_percentile(rc5_values, args.baseline_percentile)
    )

    derived = add_derived_columns(rows, args.iters, baseline_rc5)

    outdir = Path(args.outdir).resolve() if args.outdir else input_csv.parent / "plots"
    outdir.mkdir(parents=True, exist_ok=True)
    prefix = args.prefix or input_csv.stem

    normalized_csv = outdir / f"{prefix}_normalized.csv"
    top_csv = outdir / f"{prefix}_top_positions.csv"
    rc5_png = outdir / f"{prefix}_rc5_per_iter.png"
    excess_png = outdir / f"{prefix}_excess_per_iter.png"

    write_csv(normalized_csv, derived)
    write_csv(top_csv, sorted(derived, key=lambda r: float(r["rc5"]), reverse=True)[: max(0, args.top_n)])

    title_prefix = args.title or "Firestorm PHR-position rc5 scan"
    plot_rc5_per_iter(
        derived,
        rc5_png,
        f"{title_prefix}: rc5 / iteration",
        top_n=args.top_n,
    )
    plot_excess_per_iter(
        derived,
        excess_png,
        f"{title_prefix}: excess rc5 / iteration",
        baseline_rc5=baseline_rc5,
        loop_iters=args.iters,
        top_n=args.top_n,
    )

    print(f"Input CSV:       {input_csv}")
    print(f"Rows:            {len(derived)}")
    print(f"Baseline rc5:    {baseline_rc5:.0f}")
    print(f"Normalized CSV:  {normalized_csv}")
    print(f"Top positions:   {top_csv}")
    print(f"rc5 plot:        {rc5_png}")
    print(f"excess plot:     {excess_png}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
