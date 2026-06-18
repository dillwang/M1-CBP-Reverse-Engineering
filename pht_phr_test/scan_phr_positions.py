#!/usr/bin/env python3
import csv
import re
import subprocess
from pathlib import Path

ASM_FILE = Path("tb_full.S")
OUTPUT_BIN = Path("pht_tb")
CSV_OUT = Path("phr_rc5_scan.csv")

START_POS = 0
END_POS = 97
CPU_CORE = "4"
PERF_REPEATS = 5

BUILD_CMD = [
    "gcc",
    "-nostdlib",
    "-nostartfiles",
    "-ffreestanding",
    "-fno-pie",
    "-no-pie",
    "-Wl,-Tlinker.ld",
    "-Wl,--build-id=none",
    "-o",
    str(OUTPUT_BIN),
    str(ASM_FILE),
]

PERF_REPEATS = 1
EVENT = "apple_firestorm_pmu/rc5/u"


def run_cmd(cmd, check=True):
    return subprocess.run(cmd, text=True, capture_output=True, check=check)


def patch_test_pos(text: str, pos: int) -> str:
    new_text, n = re.subn(
        r"(?m)^(\s*\.set\s+TEST_POS\s*,\s*)\d+\s*$",
        rf"\g<1>{pos}",
        text,
    )
    if n == 1:
        return new_text

    new_text, n = re.subn(
        r"(?m)^(\s*BUILD_SET_PHR_FUNC\s+func_set_phr_test\s*,\s*)\d+\s*$",
        rf"\g<1>{pos}",
        text,
    )
    if n == 1:
        return new_text

    raise RuntimeError("Could not find TEST_POS or func_set_phr_test macro line to patch.")


def build_binary():
    result = run_cmd(BUILD_CMD, check=False)
    if result.returncode != 0:
        raise RuntimeError(f"Build failed.\nSTDOUT:\n{result.stdout}\nSTDERR:\n{result.stderr}")


def perf_stat_rc5():
    cmd = [
        "taskset", "-c", CPU_CORE,
        "perf", "stat",
        "-x", ",",
        "-r", str(PERF_REPEATS),
        "-e", EVENT,
        str(OUTPUT_BIN.resolve()),
    ]
    result = run_cmd(cmd, check=False)
    if result.returncode != 0:
        raise RuntimeError(f"perf stat failed.\nSTDOUT:\n{result.stdout}\nSTDERR:\n{result.stderr}")
    return result.stderr


def parse_rc5(stderr_text: str):
    for raw in stderr_text.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue

        cols = [c.strip() for c in line.split(",")]

        if any("apple_firestorm_pmu/rc5" in c for c in cols):
            val = cols[0]
            if val not in ("", "<not counted>", "<not supported>"):
                return val, line

    return None, stderr_text


def main():
    original = ASM_FILE.read_text()
    rows = []

    try:
        for pos in range(START_POS, END_POS + 1):
            print(f"[scan] test_pos={pos}")

            patched = patch_test_pos(original, pos)
            ASM_FILE.write_text(patched)

            build_binary()

            perf_text = perf_stat_rc5()
            rc5, raw_line = parse_rc5(perf_text)

            if rc5 is None:
                raise RuntimeError(f"Could not parse rc5 from perf output:\n{perf_text}")

            rows.append({
                "test_pos": pos,
                "rc5": rc5,
                "raw": raw_line,
            })

            with CSV_OUT.open("w", newline="") as f:
                writer = csv.DictWriter(f, fieldnames=["test_pos", "rc5", "raw"])
                writer.writeheader()
                writer.writerows(rows)

    finally:
        ASM_FILE.write_text(original)

    print(f"Done. Results saved to {CSV_OUT}")


if __name__ == "__main__":
    main()