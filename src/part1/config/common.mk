.SUFFIXES: .f90 .F90

# Including makefiles keep 'all' as their default target even though
# this file defines a rule (the build-mode stamp) before theirs.
.DEFAULT_GOAL := all

# Paths are resolved relative to this file, so they are correct whether
# make is run from src/part1 or from one of its subdirectories.
PART1_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)
BUILD_DIR ?= $(PART1_DIR)/build
BIN_DIR   ?= $(PART1_DIR)/bin

AR = ar -r
FC = gfortran
CC = gcc
CFLAGS = -O0 -g

# Build mode: 'make' or 'make debug' -> debug, 'make release' -> release.
# (Can also be set directly: make BUILD=release)
BUILD ?= debug

DEBUG_FLAGS   = -std=f2018 -Wall -Wextra -fcheck=all -g \
                -J$(BUILD_DIR) -I$(BUILD_DIR)
RELEASE_FLAGS = -std=f2018 -O3 -J$(BUILD_DIR) -I$(BUILD_DIR)

ifeq ($(BUILD),release)
  FFLAGS = $(RELEASE_FLAGS)
else ifeq ($(BUILD),debug)
  FFLAGS = $(DEBUG_FLAGS)
else
  $(error Unknown BUILD '$(BUILD)': use debug or release)
endif

ifndef ARCH             # Architecture, e.g., Linux
  ARCH := $(shell uname -s)
endif

LDFLAGS =

# Stamp file recording the current build mode. Switching between debug and
# release replaces the stamp and deletes objects built with the other mode's
# flags, so everything is recompiled. It also guarantees BUILD_DIR (where
# .mod files go) exists before compiling.
MODE_STAMP := $(BUILD_DIR)/.mode-$(BUILD)

$(MODE_STAMP):
	@echo "Build mode: $(BUILD)"
	@mkdir -p $(BUILD_DIR)
	@rm -f $(BUILD_DIR)/.mode-* $(BUILD_DIR)/*.mod
	@rm -f $(PART1_DIR)/*/*.o $(PART1_DIR)/*/*.x $(PART1_DIR)/*/*.a
	@touch $@

%.o: %.f90 $(MODE_STAMP)
	$(FC) $(FFLAGS) -c $<

%.o: %.F90 $(MODE_STAMP)
	$(FC) $(FFLAGS) -c $<
