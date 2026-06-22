import matplotlib.pyplot as plt
from matplotlib.ticker import StrMethodFormatter

# Data
relative_distance_bits = [11, 12, 13, 14, 15, 16, 17, 18, 19]
with_test_branch = [150234, 150187, 150392, 150420, 150548, 150725, 151278, 159838, 182457]
without_test_branch = [150213, 150109, 150250, 150335, 150251, 150131, 150315, 150403, 150638]

difference = [a - b for a, b in zip(with_test_branch, without_test_branch)]

# Plot 1: both traces
plt.figure(figsize=(10, 6))
plt.plot(relative_distance_bits, with_test_branch, marker='o', label='With Test Branch')
plt.plot(relative_distance_bits, without_test_branch, marker='o', label='Without Test Branch')
plt.title('Miss Predictions vs Relative Distance (bits)')
plt.xlabel('Relative Distance (bits)')
plt.ylabel('Miss Predictions')
plt.ylim(0, 200000)
plt.xticks(relative_distance_bits)
plt.gca().yaxis.set_major_formatter(StrMethodFormatter('{x:,.0f}'))
plt.grid(True, alpha=0.3)
plt.legend()
plt.tight_layout()
plt.savefig('miss_predictions_comparison.png', dpi=200)
plt.close()

# Plot 2: positive difference only
plt.figure(figsize=(10, 6))
plt.plot(relative_distance_bits, difference, marker='o', label='Difference (With - Without)')
plt.title('Difference in Miss Predictions vs Relative Distance (bits)')
plt.xlabel('Relative Distance (bits)')
plt.ylabel('Difference in Miss Predictions')
plt.ylim(0, 50000)
plt.xticks(relative_distance_bits)
plt.gca().yaxis.set_major_formatter(StrMethodFormatter('{x:,.0f}'))
plt.grid(True, alpha=0.3)
plt.legend()
plt.tight_layout()
plt.savefig('miss_predictions_difference.png', dpi=200)
plt.close()

print("Saved:")
print(" - miss_predictions_comparison.png")
print(" - miss_predictions_difference.png")
