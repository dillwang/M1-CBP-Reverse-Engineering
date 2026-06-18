#!/usr/bin/env python3
import argparse
import pandas as pd
import matplotlib.pyplot as plt


def infer_max_captured(group, cutoff=60000):
    
    group = group.sort_values("nbranches")
    rc5_by_n = dict(zip(group["nbranches"], group["rc5"]))

    baseline = int(rc5_by_n.get(1, 999999999))

    max_captured = 0
    for n in sorted(rc5_by_n):
        if rc5_by_n[n] <= cutoff:
            max_captured = int(n)
        else:
            break

    return max_captured, baseline, cutoff


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("csv")
    ap.add_argument("--cutoff", type=int, default=60000)
    ap.add_argument("--out-prefix", default="assoc_sweep")
    args = ap.parse_args()

    df = pd.read_csv(args.csv)

    if "phr_pos" not in df.columns:
        df["phr_pos"] = 100 - df["inject_after"]

    rows = []
    for (inject_after, phr_pos), g in df.groupby(["inject_after", "phr_pos"]):
        max_captured, baseline, cutoff = infer_max_captured(g, args.cutoff)

        rows.append({
            "inject_after": inject_after,
            "phr_pos": phr_pos,
            "max_captured_branches": max_captured,
            "baseline": baseline,
            "cutoff": cutoff,
        })

    adf = pd.DataFrame(rows).sort_values("phr_pos")
    adf.to_csv(f"{args.out_prefix}_captured.csv", index=False)

    # Plot 1: max captured branches summary
    plt.figure(figsize=(11, 4.8))
    plt.plot(
        adf["phr_pos"],
        adf["max_captured_branches"],
        marker="o",
    )
    plt.xlabel("PHRT position of k")
    plt.ylabel("Max captured branches")
    plt.title(f"Max captured probe branches vs PHRT k-position, cutoff={args.cutoff}")
    plt.grid(True, alpha=0.3)
    plt.ylim(bottom=0)
    plt.gca().invert_xaxis()  # show PHRT[99] on left, lower bits on right
    plt.tight_layout()
    plt.savefig(f"{args.out_prefix}_captured.png", dpi=200, bbox_inches="tight")
    plt.close()

    # Plot 2: raw rc5 lines for each nbranches
    plt.figure(figsize=(11, 5.2))
    for n, g in df.groupby("nbranches"):
        g = g.sort_values("phr_pos")
        plt.plot(
            g["phr_pos"],
            g["rc5"],
            marker="o",
            markersize=3,
            label=f"{n} branches",
        )

    plt.axhline(args.cutoff, linestyle="--", linewidth=1, label=f"cutoff={args.cutoff}")
    plt.xlabel("PHRT position of k")
    plt.ylabel("rc5 mispredictions")
    plt.title("Raw mispredictions vs PHRT k-position")
    plt.grid(True, alpha=0.3)
    plt.ylim(bottom=0)
    plt.legend(ncol=4, fontsize=8)
    plt.gca().invert_xaxis()
    plt.tight_layout()
    plt.savefig(f"{args.out_prefix}_raw_lines.png", dpi=200, bbox_inches="tight")
    plt.close()

    # Plot 3: heatmap-style scatter of raw rc5
    plt.figure(figsize=(11, 5.2))
    sc = plt.scatter(
        df["phr_pos"],
        df["nbranches"],
        c=df["rc5"],
        s=45,
    )

    plt.xlabel("PHRT position of k")
    plt.ylabel("Unique probe branches")
    plt.title("Raw rc5 across PHRT k-position and branch count")
    plt.yticks(sorted(df["nbranches"].unique()))
    plt.colorbar(sc, label="rc5 mispredictions")
    plt.grid(True, alpha=0.25)
    plt.gca().invert_xaxis()
    plt.tight_layout()
    plt.savefig(f"{args.out_prefix}_raw_scatter.png", dpi=200, bbox_inches="tight")
    plt.close()

    print("[done] wrote:")
    print(f"  {args.out_prefix}_captured.csv")
    print(f"  {args.out_prefix}_captured.png")
    print(f"  {args.out_prefix}_raw_lines.png")
    print(f"  {args.out_prefix}_raw_scatter.png")


if __name__ == "__main__":
    main()