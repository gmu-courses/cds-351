# Assignment 4 sample solution

Note: I ran this on my laptop which has a cache size of 128

---

## 4.1 Know your machine

Fill in from `results/machine.txt`:

| Item | Value | real64 values |
|---|---|---|
| cache line | 128 B | 8 (Note: 128 B ÷ 8 B = 16) |
| L1i per core | 192 KiB | 24,576 |
| L1d per core | 128 KiB | 16,384 |
| L2 per core | 16,384 KiB (shared per cluster) | 2,097,152 |
| L3 (shared) | 8 MiB (system-level cache) | 1,048,576 |


## 4.2 Process memory

Laptop output (the cluster will look the same; only the PIDs and baseline sizes differ):

```
1. program started                  RSS     1392 KiB   VSZ  410071264 KiB
2. after allocate                   RSS     1408       VSZ  410461920   (+381 MiB)
3. after writing the first half     RSS   196768 (+191 MiB)
4. after writing the whole array    RSS   392080 (+191 MiB)
5. after deallocate                 RSS     1504
```

a) 50e6 × 8 B = 400 MB ≈ 381 MiB. It is on the heap: it is `allocatable`, so its size is
   chosen at run time with `allocate`.
b) VSZ jumps by about the array size; RSS barely moves. `allocate` only reserves virtual
   address space; the OS assigns physical pages on the first write (first touch).
c) Each half adds about 191 MiB of RSS, matching the 200 MB written. Physical memory follows
   the pages that have been touched, not the allocation.
d) RSS returns to about its starting value. Large allocations are returned to the OS on
   `deallocate`.
e) The Fortran program is the parent; the shell (and `ps`) are children. Two copies are
   separate processes, each with its own virtual address space, so each has its own array
   and RSS. Processes do not share memory by default; threads of one process do.

## 4.3 Stride

Laptop (128-byte lines): ns/element = 0.35, 0.34, 0.66, 1.22, 3.32, 3.60, 3.66, 3.08.

a) Ratio of about 10× on the laptop, with identical arithmetic. The time is data movement,
   not computation.
b) It levels off at stride = line size / 8 B: **8 on the cluster** (64-byte lines), 16 on
   the laptop. Beyond that stride every access touches a new line, so each line delivers one
   useful value; going farther apart cannot get much worse. 
c) Stride 1: 8 of 8 values used (cluster). Stride 16: 1 of 8.
d) Stride 4000 elements (32,000 bytes): far past the plateau, so it runs at the slow end of
   the curve. This is the Fortran loop-order rule from the memory lecture, measured.


## 4.4 Working set

Laptop: the streaming curve is flat at about 0.25 ns per element, even at 256 MiB. The
pointer chase climbs from about 1.4 ns (L1), to 4–10 ns (L2 and the system-level cache),
to about 100 ns (DRAM). On the x86 cluster the streaming curve should show at least a
visible step once the array exceeds L3, though it will be much smaller than the pointer-chase
steps.

a) The pointer-chase knees should fall near the L1d, L2, and L3 sizes from 4.1. Accept
   "near" (within a factor of 2), because the TLB and other data also occupy the caches.
b) DRAM/L1 latency ratio of about 50–100×, in line with the lecture's ~1 ns vs. ~100 ns.
c) The pointer chase shows the hierarchy more clearly. Each load's address comes from the
   previous load (dependent loads), so the processor must wait the full **latency** every
   time. The streaming loop's addresses are known in advance and the accesses are
   independent, so the hardware prefetches and keeps many misses in flight at once; it is
   limited by **bandwidth**, which degrades much less across levels. This is the same
   dependent vs. independent distinction as Exercise 4.5, applied to loads instead of
   additions.
d) It keeps the total work, and therefore the total time, about the same for every size,
   so small arrays are not timed with too-short, noisy measurements and large arrays do
   not take forever. It also means small arrays are reused many times, so they stay in
   cache.

## 4.5 Dependency chains

Laptop, ns per addition (accumulators 1/2/4/8):

| build | cache | memory |
|---|---|---|
| -O0 | 0.72 / 0.51 / 0.48 / 0.48 | 0.68 / 0.54 / 0.52 / 0.51 |
| -O2 | 0.75 / 0.35 / 0.17 / 0.09 | 0.67 / 0.35 / 0.18 / 0.10 |
| -O3 -ffast-math | 0.39 / 0.34 / 0.17 / 0.09 | 0.34 / 0.33 / 0.18 / 0.10 |

a) Roughly 2×, 4×, and up to 8×. With one accumulator, each addition must wait for the
   previous one to leave the pipeline (FP-add latency of about 3–4 cycles). k independent
   chains let k additions be in flight at once. The speedup levels off once there are
   enough chains to cover latency × the number of add units (about 8 on many x86 cores),
   or when loads or vector width become the limit. The laptop has not leveled off by 8.
b) At -O0 each `s = s + x(i)` loads `s` from memory and stores it back, and the loop
   counter is handled the same way. Those memory operations and the loop overhead, not the
   add latency, set the pace, so extra chains barely matter.
c) On the cluster, expect the memory case to level off early: once the additions are fast
   enough, the loop is limited by memory bandwidth (compare with the large-size end of the
   working-set curve). The laptop does not show this because its single-core bandwidth is
   about 80 GB/s.
d) The sums differ in the last digits. Floating-point addition is not associative, so a
   different grouping rounds differently. Because of that, the compiler may not reorder the
   sum at -O2: the answer would change. `-ffast-math` permits reassociation, so the compiler
   splits and vectorizes the one-accumulator loop itself (about 2× on both machines). It
   still keeps one vector chain, so it remains slower than eight explicit accumulators.
e) Shared: `x` (read-only) and the final `s`. Private: each thread's partial sum and loop
   index. With a single shared `s`, the read–add–write sequences from different threads
   interleave and updates are lost (a race condition), so the result is too small and
   changes from run to run.

