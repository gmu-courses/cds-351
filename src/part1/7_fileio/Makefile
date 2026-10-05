include ../config/common.mk
.PHONY: clean all

EXE = test_io.x

all:  $(EXE)
	mkdir -p $(BIN_DIR)
	echo 'Installing...'$(EXE)
	cp $(EXE) $(BIN_DIR)

clean:
	rm -f *.[ox] *.mod

test_io.x: modern_file_io.o test_io.o 
	$(FC) $(FFLAGS) $^ -o test_io.x $(LDFLAGS)

# test_io uses io_manager (modern_file_io.f90), 
# so its .mod file must exist first
test_io.o: modern_file_io.o
