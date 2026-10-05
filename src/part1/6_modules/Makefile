include ../config/common.mk
.PHONY: clean all

EXE = test_basicMath.x 

all:  $(EXE)
	mkdir -p $(BIN_DIR)
	echo 'Installing...'$(EXE)
	cp $(EXE) $(BIN_DIR)

clean:
	rm -f *.[ox] *.mod

test_basicMath.x: test_basicMath.o basicMath_mod.o
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)

# test_basicMath uses basicMath_mod, so its .mod file must exist first
test_basicMath.o: basicMath_mod.o
