include ../config/common.mk
.PHONY: clean all

EXE = int_demo.x real_demo.x complex_demo.x char_demo.x logical_demo.x

all:  $(EXE)
	mkdir -p $(BIN_DIR)
	echo 'Installing...'$(EXE)
	cp $(EXE) $(BIN_DIR)

clean:
	rm -f *.[ox] *.mod

int_demo.x: int_demo.o
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)

real_demo.x: real_demo.o
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)

complex_demo.x: complex_demo.o
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)

char_demo.x: char_demo.o
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)

logical_demo.x: logical_demo.o
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)


