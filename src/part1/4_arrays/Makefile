include ../config/common.mk
.PHONY: clean all

EXE = arrays_2d.x  arrays_init.x arrays_obs.x

all:  $(EXE)
	mkdir -p $(BIN_DIR)
	echo 'Installing...'$(EXE)
	cp $(EXE) $(BIN_DIR)

clean:
	rm -f *.[ox] *.mod

arrays_2d.x: arrays_2d.o
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)

arrays_init.x: arrays_init.o
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)

arrays_obs.x: arrays_obs.o
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)
