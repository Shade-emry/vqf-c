# Simple Makefile to build VQF-C for host and Cortex-M4 (nRF52)
# Usage:
#  - Build host library:        make
#  - Build Cortex-M4 library:  make cortex-m4 CMSIS_PATH=/path/to/CMSIS
#  - Build host benchmark:     make bench
#  - Build ARM benchmark:      make bench-arm CMSIS_PATH=/path/to/CMSIS

PROJECT = vqf
SRC = src/vqf.c
LIB = lib$(PROJECT).a
ARM_LIB = lib$(PROJECT)-arm.a

CC = gcc
CC_ARM = arm-none-eabi-gcc
AR = arm-none-eabi-ar

HOST_CFLAGS = -O3 -Wall -I./src
ARM_CPU_FLAGS = -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard
ARM_CFLAGS = $(ARM_CPU_FLAGS) -O3 -Wall -DUSE_CMSIS_DSP -I./src -I$(CMSIS_PATH)/CMSIS/DSP/Include
ARM_LDFLAGS = -L$(CMSIS_PATH)/CMSIS/Lib -larm_cortexM4lf_math

.PHONY: all lib cortex-m4 bench bench-arm clean

all: lib

lib: $(LIB)

$(LIB): $(SRC)
	$(CC) $(HOST_CFLAGS) -c $(SRC) -o vqf.o
	$(AR) rcs $(LIB) vqf.o
	rm -f vqf.o

cortex-m4: $(ARM_LIB)

$(ARM_LIB): $(SRC)
	@if [ -z "$(CMSIS_PATH)" ]; then echo "CMSIS_PATH not set — set to CMSIS root or Nordic SDK root"; exit 1; fi
	$(CC_ARM) $(ARM_CFLAGS) -c $(SRC) -o vqf-arm.o
	$(AR) rcs $(ARM_LIB) vqf-arm.o
	rm -f vqf-arm.o

bench: bench/bench_cmsis

bench/bench_cmsis: bench/bench_cmsis.c $(SRC)
	$(CC) $(HOST_CFLAGS) bench/bench_cmsis.c $(SRC) -o bench/bench_cmsis -lm

bench-arm: bench/bench_cmsis-arm

bench/bench_cmsis-arm: bench/bench_cmsis.c $(SRC)
	@if [ -z "$(CMSIS_PATH)" ]; then echo "CMSIS_PATH not set"; exit 1; fi
	$(CC_ARM) $(ARM_CFLAGS) bench/bench_cmsis.c $(SRC) -o bench/bench_cmsis-arm $(ARM_LDFLAGS)

clean:
	rm -f $(LIB) $(ARM_LIB) bench/bench_cmsis bench/bench_cmsis-arm
