include ../config/common.mk
.PHONY: clean all

all: lib

lib: libutils.a

libutils.a: utils.o
	$(AR) libutils.a utils.o

clean:
	rm -f *.a *.o *.mod
