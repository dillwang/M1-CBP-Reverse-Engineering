#!/usr/bin/env python3
import argparse
import csv
import os
import re
import subprocess
import sys
from pathlib import Path

import matplotlib.pyplot as plt

def run_one(core: int, event: str, exe: str, iters: int, dummy: int) -> int:
    """
    Run one perf stat measurement and return the raw counter value (int).
    """
    cmd = [
        "taskset", "-c", str(core),
        "perf", "stat",
        "-e", event,
        exe, str(iters), str(dummy)
    ]

    # perf stat prints counters to stderr by default
    proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    if proc.returncode != 0:
        # Surface useful debug info
        raise RuntimeError(
            f"Command failed (rc={proc.returncode}): {' '.join(cmd)}\n"
            f"STDOUT:\n{proc.stdout}\n"
            f"STDERR:\n{proc.stderr}\n"
        )

    # Find the line like:
    # "     7,032      apple_firestorm_pmu/rc5/"
    # or possibly with spaces/tabs; sometimes perf prints "<not counted>" etc.
    pattern = re.compile(r"^\s*([0-9,]+)\s+" + re.escape(event) + r"\s*$", re.MULTILINE)
    m = pattern.search(proc.stderr)
    if not m:
        # Try a more forgiving match (event might be printed without trailing slash, etc.)
        # We'll search for the event substring on the same line and capture a leading number.
        pattern2 = re.compile(r"^\s*([0-9,]+)\s+.*" + re.escape(event.strip("/")) + r".*$", re.MULTILINE)
        m2 = pattern2.search(proc.stderr)
        if not m2:
            raise RuntimeError(
                f"Could not parse counter for event '{event}'.\n"
                f"STDERR was:\n{proc.stderr}\n"
            )
        raw = m2.group(1)
    else:
        raw = m.group(1)

    return int(raw.replace(",", ""))

def main():
    ap = argparse.ArgumentParser(description="Sweep dummy branches and plot misses/iter from perf stat rc5.")
    ap.add_argument("--core", type=int, default=4, help="CPU core to pin to (taskset -c). Default: 4")
    ap.add_argument("--event", type=str, default="apple_icestorm_pmu/rc5/",
                    help="perf event name. Example: apple_icestorm_pmu/rc5/ or apple_firestorm_pmu/rc5/")
    ap.add_argument("--exe", type=str, default="./phr_test", help="Path to benchmark executable. Default: ./phr_test")
    ap.add_argument("--iters", type=int, default=20_000_000, help="Iterations per run. Default: 20000000")
    ap.add_argument("--start", type=int, default=0, help="Start dummy value (inclusive). Default: 0")
    ap.add_argument("--end", type=int, default=98, help="End dummy value (inclusive). Default: 98")
    ap.add_argument("--repeats", type=int, default=1, help="Repeats per dummy value; averages results. Default: 1")
    ap.add_argument("--outdir", type=str, default="out", help="Output directory. Default: out")
    args = ap.parse_args()

    exe_path = Path(args.exe)
    if not exe_path.exists():
        print(f"ERROR: executable not found: {exe_path}", file=sys.stderr)
        sys.exit(1)

    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    csv_path = outdir / "phr_rc5_sweep.csv"
    png_path = outdir / "phr_rc5_sweep.png"

    xs = []
    ys = []

    print(f"Running sweep dummy={args.start}..{args.end} (iters={args.iters}, repeats={args.repeats})")
    print(f"Pinning to core {args.core}, event '{args.event}', exe '{args.exe}'")
    print(f"Writing CSV: {csv_path}")
    print(f"Will write plot: {png_path}")
    print()

    with open(csv_path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["dummy", "rc5_total", "misses_per_iter"])

        for dummy in range(args.start, args.end + 1):
            total = 0
            for r in range(args.repeats):
                rc5 = run_one(args.core, args.event, args.exe, args.iters, dummy)
                total += rc5
            avg_rc5 = total / args.repeats
            misses_per_iter = avg_rc5 / args.iters

            xs.append(dummy+2)
            ys.append(misses_per_iter)

            w.writerow([dummy+2, f"{avg_rc5:.3f}", f"{misses_per_iter:.12f}"])
            print(f"dummy={dummy+2:3d}  rc5(avg)={avg_rc5:12.3f}  miss/iter={misses_per_iter:.8f}")

    # Plot
    plt.figure()
    plt.plot(xs, ys)
    plt.xlabel("Number of branches (dummy)")
    plt.ylabel("misses per iteration (rc5 / iters)")
    plt.title(f"PHR sweep")
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(png_path, dpi=200)

    print("\nDone.")
    print(f"CSV saved to: {csv_path}")
    print(f"Plot saved to: {png_path}")

if __name__ == "__main__":
    main()
