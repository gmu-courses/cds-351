include ../config/common.mk
.PHONY: clean all

EXE = hello.x

all:  $(EXE)
	mkdir -p $(BIN_DIR)
	echo 'Installing...'$(EXE)
	cp $(EXE) $(BIN_DIR)

clean:
	rm -f *.[ox] *.mod

hello.x: hello.o
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)
