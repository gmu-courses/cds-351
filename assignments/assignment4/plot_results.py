"""Plot the Assignment 4 results.

Reads the CSV files that `make run` writes to results/ and saves one PNG per
experiment. Run from the assignment4 directory:

    python3 plot_results.py

Missing result files are skipped, so you can plot as you go.
"""
import csv
from pathlib import Path

import matplotlib
matplotlib.use("Agg")                    # write files; no display needed on the cluster
import matplotlib.pyplot as plt

RESULTS = Path("results")
COLORS = ["#2a78b5", "#d9822b", "#3b9a5b"]   # fixed order: first, second, third series


def read_csv(name):
    """Return the rows of results/<name> as dictionaries, skipping '#' lines."""
    path = RESULTS / name
    if not path.exists():
        print(f"skipping {path}: not found")
        return None
    with path.open() as f:
        return list(csv.DictReader(line for line in f if not line.startswith("#")))


def read_cache_latency():
    """Return (sizes, ns) from cache_latency.x output, or None."""
    path = RESULTS / "cache_latency.txt"
    if not path.exists():
        return None
    sizes, ns = [], []
    for line in path.read_text().splitlines():
        parts = line.split()
        if len(parts) == 2 and parts[0].isdigit():
            sizes.append(int(parts[0]))
            ns.append(float(parts[1]))
    return sizes, ns


def finish(ax, title, xlabel, ylabel, filename):
    ax.set_title(title)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.grid(True, which="major", color="#dddddd", linewidth=0.8)
    ax.set_axisbelow(True)
    if ax.get_legend_handles_labels()[0]:
        ax.legend(frameon=False)
    ax.figure.tight_layout()
    ax.figure.savefig(filename, dpi=150)
    print(f"wrote {filename}")


def plot_stride():
    rows = read_csv("stride.csv")
    if not rows:
        return
    stride = [int(r["stride"]) for r in rows]
    ns = [float(r["ns_per_element"]) for r in rows]
    fig, ax = plt.subplots(figsize=(6, 4))
    ax.plot(stride, ns, "o-", color=COLORS[0], linewidth=2, markersize=6)
    ax.set_xscale("log", base=2)
    ax.set_xticks(stride, [str(s) for s in stride])
    ax.set_ylim(bottom=0)
    finish(ax, "Same updates, different stride", "stride (elements)",
           "time per element (ns)", "stride.png")


def plot_working_set():
    rows = read_csv("working_set.csv")
    if not rows:
        return
    fig, ax = plt.subplots(figsize=(7, 4))
    ax.plot([int(r["size_kib"]) for r in rows],
            [float(r["ns_per_element"]) for r in rows],
            "o-", color=COLORS[0], linewidth=2, markersize=6,
            label="working_set (streaming updates)")
    chase = read_cache_latency()
    if chase:
        ax.plot(*chase, "s-", color=COLORS[1], linewidth=2, markersize=6,
                label="cache_latency (pointer chase)")
    ax.set_xscale("log", base=2)
    ax.set_yscale("log")
    finish(ax, "Time per access vs. working-set size", "array size (KiB)",
           "time per access (ns)", "working_set.png")


def plot_ilp():
    builds = [("ilp_O0.csv", "-O0"), ("ilp_O2.csv", "-O2"),
              ("ilp_fast.csv", "-O3 -ffast-math")]
    data = [(read_csv(name), label) for name, label in builds]
    if not any(rows for rows, _ in data):
        return
    fig, axes = plt.subplots(1, 2, figsize=(10, 4), sharey=True)
    for ax, case in zip(axes, ["cache", "memory"]):
        for (rows, label), color in zip(data, COLORS):
            if not rows:
                continue
            sel = [r for r in rows if r["case"] == case]
            ax.plot([int(r["accumulators"]) for r in sel],
                    [float(r["ns_per_add"]) for r in sel],
                    "o-", color=color, linewidth=2, markersize=6, label=label)
        ax.set_xscale("log", base=2)
        ax.set_xticks([1, 2, 4, 8], ["1", "2", "4", "8"])
        ax.set_ylim(bottom=0)
        ax.set_title(f"array in {case}")
        ax.set_xlabel("accumulators")
        ax.grid(True, color="#dddddd", linewidth=0.8)
        ax.set_axisbelow(True)
    axes[0].set_ylabel("time per addition (ns)")
    axes[0].legend(frameon=False)
    fig.suptitle("Breaking the dependency chain")
    fig.tight_layout()
    fig.savefig("ilp.png", dpi=150)
    print("wrote ilp.png")


if __name__ == "__main__":
    plot_stride()
    plot_working_set()
    plot_ilp()
