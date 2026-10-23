FC            = gfortran
DEBUG_FLAGS   = -std=f2018 -Wall -Wextra -fcheck=all -g -Jbuild -Ibuild
RELEASE_FLAGS = -std=f2018 -O3 -Jbuild -Ibuild
FFLAGS        = $(DEBUG_FLAGS)

TARGET = bin/matrix_app.x

OBJECTS = build/matrix_types_mod.o \
          build/matrix_mod.o \
          build/io_mod.o \
          build/main.o

.PHONY: all run clean dirs debug release

all: dirs $(TARGET)

dirs:
	mkdir -p build bin output

$(TARGET): $(OBJECTS)
	$(FC) $(OBJECTS) -o $@

build/matrix_types_mod.o: src/matrix_types_mod.f90 | dirs
	$(FC) $(FFLAGS) -c $< -o $@

build/matrix_mod.o: src/matrix_mod.f90 build/matrix_types_mod.o | dirs
	$(FC) $(FFLAGS) -c $< -o $@

build/io_mod.o: src/io_mod.f90 build/matrix_types_mod.o | dirs
	$(FC) $(FFLAGS) -c $< -o $@

build/main.o: src/main.f90 build/matrix_types_mod.o \
              build/matrix_mod.o build/io_mod.o | dirs
	$(FC) $(FFLAGS) -c $< -o $@

run: all
	./$(TARGET)

debug:
	$(MAKE) clean
	$(MAKE) FFLAGS="$(DEBUG_FLAGS)" all

release:
	$(MAKE) clean
	$(MAKE) FFLAGS="$(RELEASE_FLAGS)" all

clean:
	$(RM) build/*.o build/*.mod $(TARGET) output/report.txt

