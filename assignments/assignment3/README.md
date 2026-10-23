# Assignment 3 sample solution

This solution refactors the Assignment 2 matrices and validation results into derived-type
objects. Run commands from this `assignment3` directory.

## Build and run

```bash
make
make run
make clean

make debug
make run

make release
make run
```

The test matrices produce

```text
C = [58 64; 139 154]
```

with a checksum of 415. The relative error should be zero or close to machine rounding, and
the report should mark the calculation as verified.

## Incremental-build observations

1. Immediately after a successful build, `make` runs no compile or link recipes because
   every compiled target exists and is newer than its prerequisites. The inexpensive
   `mkdir -p` recipe may still run because `dirs` is a phony target.
2. After `touch src/matrix_mod.f90`, Make recompiles `matrix_mod.o` and `main.o`, then relinks
   the executable. The `main.o` rule records its dependency on `matrix_mod.o`.
3. After `touch src/matrix_types_mod.f90`, Make recompiles `matrix_types_mod.o`, both modules
   that use it, and `main.o`, then relinks. A change near the base of the dependency graph
   affects more downstream targets.

These explicit object dependencies are conservative: an implementation-only source change
may rebuild a user even if the generated module interface did not actually change. That is
acceptable for this small instructional Makefile.

## Allocatable-component assignment

For `copy = original`, intrinsic derived-type assignment copies the scalar components and
allocates `copy%values` as needed before copying the array elements. The two allocatable
components are independent afterward. This ownership behavior is convenient and safe, but
copying a large matrix requires additional memory and moves every element. At HPC scales,
that hidden-looking data movement can take significant time and consume substantial memory.

## Limitations

The text-file reader is deliberately simple, the matrix names are derived from filenames,
and the Makefile uses a clean rebuild when switching build modes. A larger application would
usually use a binary scientific format, richer validation, and separate build directories
for debug and release objects.
