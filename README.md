# CDS-351

This project contains educational resources and software used for CDS-351 
(Elements of High-Performance Computing).

CDS-351 explores aspects of high-performance computing (HPC) based on a 
diverse set of tools, including Unix basics, file systems, command scripts, 
Git, HPC programming (C/C++,Fortran), basics of parallel programming, 
and HPC system architectures.

## Prerequisites

- A Unix-like shell (Linux or macOS)
- `gfortran` (GCC 10 or newer) with OpenMP support (`-fopenmp`)
- `make`
- `python3`. `matplotlib` is optional and is only used for plotting results.

On macOS, Homebrew's `gcc` package provides `gfortran` and OpenMP.

## Repository layout

| Directory | Contents |
|-----------|----------|
| `src/part1/` | Fortran fundamentals: intro, variables, control flow, arrays, procedures, modules, file I/O, derived types, and a small library (`lib/`) |
| `src/part2/` | How the hardware affects performance: memory and I/O latency and bandwidth (`memory/`), pipelining, instruction-level parallelism, and processes and threads (`processes/`) |
| `src/part3/` | Shared-memory parallel programming with OpenMP: parallel regions, work-sharing, reductions, scheduling, synchronization, tasks, and a heat-diffusion case study (`heat/`) |
| `exercises/` | In-class exercises (`icN/`) |
| `assignments/` | Homework assignments. Each has its own `README.md` with instructions |

## Building and running the examples

### Part 1: Fortran fundamentals

Part 1 is built from its top-level Makefile, which uses shared settings in
`src/part1/config/common.mk`. Executables are copied to `src/part1/bin/`.

```bash
cd src/part1
make               # debug build: runtime checks and warnings enabled
make release       # optimized build (-O3)
make -C 4_arrays   # build a single topic
make clean         # remove objects; 'make allclean' also removes bin/ and build/
```

### Part 2: Memory and processor performance

Each subdirectory has its own Makefile. These programs are timing
experiments, so they are built with optimization and without runtime checks.

```bash
cd src/part2/memory
make
./mem_latency.x
```

### Part 3: OpenMP

Compile each example with OpenMP enabled. Use `OMP_NUM_THREADS` to set the
number of threads:

```bash
cd src/part3
gfortran -std=f2018 -O3 -fopenmp pi_reduction.f90 -o pi_reduction.x
OMP_NUM_THREADS=4 ./pi_reduction.x
```

The heat-diffusion example has its own Makefile:

```bash
cd src/part3/heat
make run THREADS=8   # run every version with 8 threads
make scaling         # time the parallel version with 1, 2, 4 and 8 threads
```

### Assignments

Assignments 3 and later have a self-contained Makefile. For example:

```bash
cd assignments/assignment4
make run    # build, then run the experiments into results/
make plot   # plot the results
```

See each assignment's `README.md` for the full instructions.

## License

### Documentation and Educational Materials
This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/).

### Source Code
This project is licensed under the [MIT License](LICENSE).
