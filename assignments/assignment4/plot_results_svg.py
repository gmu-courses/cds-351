"""Plot the Assignment 4 results without matplotlib.

The course cluster has Python but not matplotlib, so this script draws the
same three plots as plot_results.py using only the Python standard library.
It writes SVG files, which any web browser can open. Run from the
assignment4 directory:

    python3 plot_results_svg.py

It writes stride.svg, working_set.svg, and ilp.svg. To look at them, copy
them to your laptop (run this on the laptop, not on the cluster):

    scp 'USER@rhcds10.mesa.gmu.edu:PATH/TO/assignment4/*.svg' .

Missing result files are skipped, so you can plot as you go.
"""
import csv
import math
from pathlib import Path
from xml.sax.saxutils import escape

RESULTS = Path("results")
COLORS = ["#2a78b5", "#d9822b", "#3b9a5b"]   # fixed order: first, second, third series
GRID = "#dddddd"
FONT = 'font-family="Helvetica, Arial, sans-serif"'


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


# ---------------------------------------------------------------- axes and ticks

class Axes:
    """A plotting area that maps data coordinates to SVG pixels."""

    def __init__(self, left, top, width, height, xlim, ylim, xlog=False, ylog=False):
        self.left, self.top, self.width, self.height = left, top, width, height
        self.xlim, self.ylim, self.xlog, self.ylog = xlim, ylim, xlog, ylog

    @staticmethod
    def _fraction(v, lo, hi, log):
        if log:
            v, lo, hi = math.log(v), math.log(lo), math.log(hi)
        return (v - lo) / (hi - lo)

    def px(self, x):
        return self.left + self.width * self._fraction(x, *self.xlim, self.xlog)

    def py(self, y):
        return self.top + self.height * (1 - self._fraction(y, *self.ylim, self.ylog))


def linear_ticks(hi):
    """Ticks from 0 to just above hi, with a round step (1, 2, 2.5, or 5 x 10^k)."""
    raw = hi / 5
    power = 10 ** math.floor(math.log10(raw))
    step = next(m * power for m in (1, 2, 2.5, 5, 10) if m * power >= raw)
    count = math.ceil(hi / step - 1e-9)
    return [k * step for k in range(count + 1)]


def log_range(values, factor=1.4):
    """Limits for a log axis with a little room on both sides."""
    return min(values) / factor, max(values) * factor


def number(v):
    """A short label for a tick value."""
    return f"{v:g}"


def size_label(kib):
    """4 -> '4 KiB', 1024 -> '1 MiB', 262144 -> '256 MiB'."""
    for unit in ("KiB", "MiB", "GiB"):
        if kib < 1024:
            return f"{kib:g} {unit}"
        kib /= 1024
    return f"{kib:g} TiB"


# ---------------------------------------------------------------- SVG elements

def text(x, y, s, anchor="middle", size=13, extra=""):
    return (f'<text x="{x:.1f}" y="{y:.1f}" text-anchor="{anchor}" font-size="{size}" '
            f'{FONT} {extra}>{escape(s)}</text>')


def frame(ax, xticks, yticks, title, xlabel, ylabel):
    """Grid lines, box, tick labels, axis labels, and title of one Axes."""
    out = []
    bottom, right = ax.top + ax.height, ax.left + ax.width
    for value, label in xticks:
        x = ax.px(value)
        out.append(f'<line x1="{x:.1f}" y1="{ax.top}" x2="{x:.1f}" y2="{bottom}" stroke="{GRID}"/>')
        out.append(text(x, bottom + 18, label))
    for value, label in yticks:
        y = ax.py(value)
        out.append(f'<line x1="{ax.left}" y1="{y:.1f}" x2="{right}" y2="{y:.1f}" stroke="{GRID}"/>')
        out.append(text(ax.left - 6, y + 4, label, anchor="end"))
    out.append(f'<rect x="{ax.left}" y="{ax.top}" width="{ax.width}" height="{ax.height}" '
               f'fill="none" stroke="black"/>')
    out.append(text(ax.left + ax.width / 2, ax.top - 10, title, size=15))
    out.append(text(ax.left + ax.width / 2, bottom + 40, xlabel))
    if ylabel:
        cx, cy = ax.left - 52, ax.top + ax.height / 2
        out.append(text(cx, cy, ylabel, extra=f'transform="rotate(-90 {cx:.1f} {cy:.1f})"'))
    return out


def marker(x, y, color, shape):
    if shape == "square":
        return f'<rect x="{x - 4:.1f}" y="{y - 4:.1f}" width="8" height="8" fill="{color}"/>'
    return f'<circle cx="{x:.1f}" cy="{y:.1f}" r="4.5" fill="{color}"/>'


def series(ax, xs, ys, color, shape="circle"):
    """A line with markers."""
    points = " ".join(f"{ax.px(x):.1f},{ax.py(y):.1f}" for x, y in zip(xs, ys))
    out = [f'<polyline points="{points}" fill="none" stroke="{color}" stroke-width="2.5"/>']
    out += [marker(ax.px(x), ax.py(y), color, shape) for x, y in zip(xs, ys)]
    return out


def legend(x, y, entries):
    """entries: (label, color, shape). (x, y) is the top-left corner."""
    width = 40 + 7.5 * max(len(label) for label, _, _ in entries)
    out = [f'<rect x="{x}" y="{y}" width="{width:.0f}" height="{10 + 20 * len(entries)}" '
           f'fill="white" fill-opacity="0.85"/>']
    for k, (label, color, shape) in enumerate(entries):
        cy = y + 15 + 20 * k
        out.append(f'<line x1="{x + 6}" y1="{cy}" x2="{x + 30}" y2="{cy}" stroke="{color}" stroke-width="2.5"/>')
        out.append(marker(x + 18, cy, color, shape))
        out.append(text(x + 36, cy + 4, label, anchor="start"))
    return out


def save(filename, width, height, elements):
    svg = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
           f'viewBox="0 0 {width} {height}">',
           f'<rect width="{width}" height="{height}" fill="white"/>',
           *elements, "</svg>"]
    Path(filename).write_text("\n".join(svg) + "\n")
    print(f"wrote {filename}")


# ---------------------------------------------------------------- the three plots

def plot_stride():
    rows = read_csv("stride.csv")
    if not rows:
        return
    stride = [int(r["stride"]) for r in rows]
    ns = [float(r["ns_per_element"]) for r in rows]
    yticks = linear_ticks(max(ns))
    ax = Axes(80, 40, 500, 300, log_range(stride, 1.25), (0, yticks[-1]), xlog=True)
    out = frame(ax, [(s, str(s)) for s in stride], [(v, number(v)) for v in yticks],
                "Same updates, different stride", "stride (elements)", "time per element (ns)")
    out += series(ax, stride, ns, COLORS[0])
    save("stride.svg", 620, 400, out)


def plot_working_set():
    rows = read_csv("working_set.csv")
    if not rows:
        return
    curves = [([int(r["size_kib"]) for r in rows], [float(r["ns_per_element"]) for r in rows],
               "working_set (streaming updates)", COLORS[0], "circle")]
    chase = read_cache_latency()
    if chase:
        curves.append((*chase, "cache_latency (pointer chase)", COLORS[1], "square"))

    all_x = [x for c in curves for x in c[0]]
    all_y = [y for c in curves for y in c[1]]
    lo, hi = math.floor(math.log10(min(all_y))), math.ceil(math.log10(max(all_y)))
    ax = Axes(80, 40, 600, 300, log_range(all_x), (10.0 ** lo, 10.0 ** hi), xlog=True, ylog=True)
    xticks = sorted(set(all_x))[::2]
    out = frame(ax, [(x, size_label(x)) for x in xticks],
                [(10.0 ** k, number(10.0 ** k)) for k in range(lo, hi + 1)],
                "Time per access vs. working-set size", "array size",
                "time per access (ns)")
    for xs, ys, _, color, shape in curves:
        out += series(ax, xs, ys, color, shape)
    out += legend(ax.left + 10, ax.top + 10, [(label, color, shape) for _, _, label, color, shape in curves])
    save("working_set.svg", 720, 400, out)


def plot_ilp():
    builds = [("ilp_O0.csv", "-O0"), ("ilp_O2.csv", "-O2"),
              ("ilp_fast.csv", "-O3 -ffast-math")]
    data = [(read_csv(name), label, color) for (name, label), color in zip(builds, COLORS)]
    data = [d for d in data if d[0]]
    if not data:
        return
    yticks = linear_ticks(max(float(r["ns_per_add"]) for rows, _, _ in data for r in rows))
    out = [text(500, 22, "Breaking the dependency chain", size=16)]
    for k, case in enumerate(["cache", "memory"]):
        ax = Axes(80 + 470 * k, 60, 400, 300, (1 / 1.25, 8 * 1.25), (0, yticks[-1]), xlog=True)
        out += frame(ax, [(a, str(a)) for a in (1, 2, 4, 8)], [(v, number(v)) for v in yticks],
                     f"array in {case}", "accumulators", "time per addition (ns)" if k == 0 else "")
        for rows, _, color in data:
            sel = [r for r in rows if r["case"] == case]
            out += series(ax, [int(r["accumulators"]) for r in sel],
                          [float(r["ns_per_add"]) for r in sel], color)
        if k == 0:
            out += legend(ax.left + ax.width - 160, ax.top + 10,
                          [(label, color, "circle") for _, label, color in data])
    save("ilp.svg", 1000, 420, out)


if __name__ == "__main__":
    plot_stride()
    plot_working_set()
    plot_ilp()
