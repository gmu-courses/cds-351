include ../config/common.mk
.PHONY: clean all

EXE = hurr_cat.x factorial.x if_decisions.x pi_leibniz.x

all:  $(EXE)
	mkdir -p $(BIN_DIR)
	echo 'Installing...'$(EXE)
	cp $(EXE) $(BIN_DIR)

clean:
	rm -f *.[ox] *.mod

hurr_cat.x: hurr_cat.o
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)

factorial.x: factorial.o
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)

if_decisions.x: if_decisions.o
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)

pi_leibniz.x: pi_leibniz.o
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)

