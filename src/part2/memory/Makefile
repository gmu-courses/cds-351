# Memory and I/O performance examples.
# These are timing experiments, so they are built with optimization and
# without the run-time checks used for debugging.

FC     = gfortran
FFLAGS = -std=f2018 -O3

EXE = io_bandwidth.x io_latency.x mem_bandwidth.x mem_latency.x cache_latency.x

.PHONY: all clean

all: $(EXE)

%.x: %.f90
	$(FC) $(FFLAGS) $< -o $@

clean:
	rm -f *.x *.o *.mod test.bin
