#!/usr/bin/env python3
import argparse
import csv
import re
import subprocess
from pathlib import Path

RC5_RE = re.compile(r"^\s*([\d,]+)\s+apple_firestorm_pmu/rc5/u", re.MULTILINE)

def run_cmd(cmd, check=True):
    p = subprocess.run(cmd, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if check and p.returncode != 0:
        raise RuntimeError(
            f"Command failed: {' '.join(cmd)}\n"
            f"stdout:\n{p.stdout}\n"
            f"stderr:\n{p.stderr}\n"
        )
    return p

def parse_rc5(perf_text: str) -> int:
    m = RC5_RE.search(perf_text)
    if not m:
        raise RuntimeError(f"Could not parse rc5 from perf output:\n{perf_text}")
    return int(m.group(1).replace(",", ""))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--inject-start", type=int, default=0)
    ap.add_argument("--inject-end", type=int, default=98)
    ap.add_argument("--max-branches", type=int, default=12)
    ap.add_argument("--total-labels", type=int, default=99)
    ap.add_argument("--linker", default="linker.ld")
    ap.add_argument("--gen", default="./gen_tb_assoc.py")
    ap.add_argument("--out", default="assoc_sweep.csv")
    ap.add_argument("--cpu", default="4")
    ap.add_argument("--zero-phrb", action="store_true")
    args = ap.parse_args()

    if args.zero_phrb and args.inject_end >= args.total_labels:
        raise SystemExit(
            "--zero-phrb mode cannot use inject_after == total_labels. "
            f"Use --inject-end {args.total_labels - 1}."
        )

    out_path = Path(args.out)

    with out_path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["inject_after", "phr_pos", "nbranches", "rc5"])
        writer.writeheader()

        for inject_after in range(args.inject_start, args.inject_end + 1):
            phr_pos = args.total_labels - inject_after

            for nbranches in range(1, args.max_branches + 1):
                print(f"[sweep] inject_after={inject_after} nbranches={nbranches}", flush=True)

                gen_cmd = [
                    "python3", args.gen,
                    "--inject-after", str(inject_after),
                    "--nbranches", str(nbranches),
                    "--max-branches", str(args.max_branches),
                    "--total-labels", str(args.total_labels),
                    "-o", "tb_auto.S",
                ]

                if args.zero_phrb:
                    gen_cmd.append("--zero-phrb")

                run_cmd(gen_cmd)

                run_cmd([
                    "gcc",
                    "-nostdlib", "-nostartfiles", "-ffreestanding",
                    "-fno-pie", "-no-pie",
                    f"-Wl,-T{args.linker}",
                    "-Wl,--build-id=none",
                    "-o", "pht_tb_auto",
                    "tb_auto.S",
                ])

                p = run_cmd([
                    "taskset", "-c", args.cpu,
                    "perf", "stat",
                    "-e", "apple_firestorm_pmu/rc5/",
                    "./pht_tb_auto",
                ])

                perf_text = p.stdout + "\n" + p.stderr
                rc5 = parse_rc5(perf_text)

                writer.writerow({
                    "inject_after": inject_after,
                    "phr_pos": phr_pos,
                    "nbranches": nbranches,
                    "rc5": rc5,
                })
                f.flush()

    print(f"[done] wrote {out_path}", flush=True)

if __name__ == "__main__":
    main()
