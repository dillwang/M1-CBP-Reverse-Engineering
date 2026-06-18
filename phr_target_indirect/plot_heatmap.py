import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

CSV = "results.csv"
DUMMY_OVERHEAD = 2
BIT_MIN, BIT_MAX = 2, 31
X_MIN, X_MAX = None, None


df = pd.read_csv(CSV)

df.columns = [c.strip().lower() for c in df.columns]

need = {"bit", "ndummy"}
if not need.issubset(df.columns):
    raise SystemExit(f"CSV must contain columns: {sorted(list(need))}. Got: {df.columns.tolist()}")

if "miss_per_iter" in df.columns:
    df["rate"] = df["miss_per_iter"].astype(float)
elif "rc5" in df.columns and "iters" in df.columns:
    df["rate"] = df["rc5"].astype(float) / df["iters"].astype(float)
else:
    raise SystemExit("CSV must have either 'miss_per_iter' or both 'rc5' and 'iters'.")

df = df[(df["bit"] >= BIT_MIN) & (df["bit"] <= BIT_MAX)].copy()
df["dummy_effective"] = df["ndummy"].astype(int) + DUMMY_OVERHEAD

mat = df.pivot_table(index="bit", columns="dummy_effective", values="rate", aggfunc="mean")

mat = mat.sort_index(axis=0).sort_index(axis=1)

if X_MIN is not None:
    mat = mat.loc[:, mat.columns >= X_MIN]
if X_MAX is not None:
    mat = mat.loc[:, mat.columns <= X_MAX]

plt.figure(figsize=(11, 8))
im = plt.imshow(
    mat.values,
    aspect="auto",
    origin="upper",
    interpolation="nearest",
)

plt.xticks(
    ticks=np.arange(mat.shape[1]),
    labels=mat.columns.astype(int),
    rotation=90
)
plt.yticks(
    ticks=np.arange(mat.shape[0]),
    labels=mat.index.astype(int)
)

plt.xlabel("Dummy branches (effective = ndummy + 2)")
plt.ylabel("Toggle bit")
cbar = plt.colorbar(im)
cbar.set_label("Misprediction rate")

plt.tight_layout()
plt.savefig("heatmap.png", dpi=250)
plt.show()
