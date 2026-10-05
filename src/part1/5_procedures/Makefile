include ../config/common.mk
.PHONY: clean all

EXE = array_args.x sample_func.x sample_sub.x coin.x ext_func_test.x \
	 pass_by_ref.x

all:  $(EXE)
	mkdir -p $(BIN_DIR)
	echo 'Installing...'$(EXE)
	cp $(EXE) $(BIN_DIR)

clean:
	rm -f *.[ox] *.mod

sample_func.x: sample_func.o
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)

sample_sub.x: sample_sub.o
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)

coin.x: coin.o
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)

ext_func_test.x: ext_func.o ext_func_test.o
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)

pass_by_ref.x: pass_by_ref.o
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)

array_args.x: array_args.o
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)

