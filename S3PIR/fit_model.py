import pandas as pd
import numpy as np
from scipy.optimize import curve_fit

# Load data
df = pd.read_csv('amortized_times.csv')

# Prepare X and y
log_dbsize = df['LogDBSize'].values
entry_size = df['EntrySize'].values
y = df['AmortizedTime_ms'].values

# Define the model
def model(X, a, alpha, beta, b):
    log_dbsize, entry_size = X
    n = 2 ** log_dbsize
    return a * (n ** alpha) * (entry_size ** beta) + b

# Fit the model
popt, pcov = curve_fit(model, (log_dbsize, entry_size), y, p0=[1e-8, 1, 1, 0])

a, alpha, beta, b = popt

print(f"Best fit parameters:")
print(f"a = {a:.3e}")
print(f"alpha = {alpha:.3f}")
print(f"beta = {beta:.3f}")
print(f"b = {b:.3e}")

# Optional: Show fit vs real
import matplotlib.pyplot as plt
y_pred = model((log_dbsize, entry_size), *popt)

plt.figure(figsize=(8,5))
plt.scatter(y, y_pred)
plt.xlabel("Actual Amortized Time (ms)")
plt.ylabel("Predicted Amortized Time (ms)")
plt.title("Actual vs Predicted Amortized Time")
plt.grid(True)
plt.plot([y.min(), y.max()], [y.min(), y.max()], 'k--')
plt.tight_layout()
plt.show()
