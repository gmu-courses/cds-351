include config/common.mk

DIRS := 1_intro \
    2_variables \
    3_control \
    4_arrays \
    5_procedures  \
    6_modules  \
    7_fileio \
    lib

.PHONY: all debug release clean allclean $(DIRS)

all: $(DIRS)

# BUILD given on the command line is passed down to every sub-make.
debug:
	$(MAKE) all BUILD=debug

release:
	$(MAKE) all BUILD=release

$(DIRS):
	$(MAKE) --directory=$@

clean:
	@for d in $(DIRS) ; do \
	$(MAKE) -C $$d clean ; done

allclean: clean
	rm -rf $(BIN_DIR) $(BUILD_DIR)
