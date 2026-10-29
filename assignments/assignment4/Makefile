# Assignment 4: memory, processes, and instruction-level parallelism
#
# These are timing experiments, so programs are built with optimization and
# without the run-time checks used for debugging. ilp_sum is built three
# times with different flags so the flags can be compared.
#
#   make          build every program
#   make info     record the machine description in results/machine.txt
#   make run      build, record the machine, and run every experiment
#   make plot     plot the CSV files in results/
#   make clean    remove generated files (keeps results/)

FC     = gfortran
FFLAGS = -std=f2018 -O2 -Jbuild -Ibuild

PROGRAMS = bin/memory_footprint.x bin/stride.x bin/working_set.x bin/cache_latency.x \
           bin/ilp_sum_O0.x bin/ilp_sum_O2.x bin/ilp_sum_fast.x

.PHONY: all info run plot clean dirs

all: dirs $(PROGRAMS)

dirs:
	mkdir -p build bin results

build/procinfo_mod.o: src/procinfo_mod.f90 | dirs
	$(FC) $(FFLAGS) -c $< -o $@

bin/memory_footprint.x: src/memory_footprint.f90 build/procinfo_mod.o | dirs
	$(FC) $(FFLAGS) $^ -o $@

bin/stride.x: src/stride.f90 | dirs
	$(FC) $(FFLAGS) $< -o $@

bin/working_set.x: src/working_set.f90 | dirs
	$(FC) $(FFLAGS) $< -o $@

bin/cache_latency.x: src/cache_latency.f90 | dirs
	$(FC) $(FFLAGS) $< -o $@

bin/ilp_sum_O0.x: src/ilp_sum.f90 | dirs
	$(FC) -std=f2018 -O0 $< -o $@

bin/ilp_sum_O2.x: src/ilp_sum.f90 | dirs
	$(FC) -std=f2018 -O2 $< -o $@

bin/ilp_sum_fast.x: src/ilp_sum.f90 | dirs
	$(FC) -std=f2018 -O3 -ffast-math $< -o $@

info: | dirs
	{ hostname; date; echo; \
	  lscpu 2>/dev/null || sysctl hw 2>/dev/null; echo; \
	  echo "cache line size (bytes):"; \
	  getconf LEVEL1_DCACHE_LINESIZE 2>/dev/null || sysctl -n hw.cachelinesize; \
	} > results/machine.txt
	@echo "wrote results/machine.txt"

run: all info
	./bin/memory_footprint.x   > results/memory_footprint.txt
	./bin/stride.x             > results/stride.csv
	./bin/working_set.x        > results/working_set.csv
	./bin/cache_latency.x      > results/cache_latency.txt
	./bin/ilp_sum_O0.x         > results/ilp_O0.csv
	./bin/ilp_sum_O2.x         > results/ilp_O2.csv
	./bin/ilp_sum_fast.x       > results/ilp_fast.csv
	@echo "results are in results/"

plot:
	python3 plot_results.py

clean:
	rm -rf build bin *.png
