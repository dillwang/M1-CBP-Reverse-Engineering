#!/usr/bin/env python3
# gen_phr_dummy.py
MAX_DUMMY = 256

out = []

# Jump table 
for n in range(MAX_DUMMY + 1):
    out.append(f"    .8byte entry_{n}\n")
out.append("\n")

# Entries
out.append("    .align 4\n")
out.append("entry_0:\n")
out.append("    b dummy_done\n\n")

for n in range(1, MAX_DUMMY + 1):
    out.append("    .align 4\n")
    out.append(f"entry_{n}:\n")
    # n unconditional taken branches with unique PC
    for i in range(n):
        out.append(f"    b  {i+1}f\n")
        out.append(f"{i+1}:\n")
    out.append("    b dummy_done\n\n")

print("".join(out), end="")
