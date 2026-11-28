# Native setup installs OSS CAD Suite in ~/opt.
# Prepending it here also makes VS Code Tasks work when launched from GUI.
OSS_CAD_BIN ?= $(HOME)/opt/oss-cad-suite/bin
export PATH := $(OSS_CAD_BIN):$(PATH)

VERILATOR ?= verilator
SBY ?= sby
BASH ?= bash
RISCV_GCC ?= riscv64-unknown-elf-gcc
RISCV_OBJDUMP ?= riscv64-unknown-elf-objdump

.PHONY: doctor lint sim-alu formal-alu wave-alu toolchain-check test clean

doctor:
	$(BASH) scripts/check-env.sh

lint:
	$(VERILATOR) --lint-only --sv -Wall --top-module alu rtl/alu.sv

sim-alu:
	mkdir -p build/obj_dir
	$(VERILATOR) --binary --trace --timing -Wall --top-module tb_alu --Mdir build/obj_dir tb/tb_alu.sv rtl/alu.sv
	./build/obj_dir/Vtb_alu

formal-alu:
	$(SBY) -f -d build/alu_formal formal/alu.sby

wave-alu: sim-alu
	gtkwave build/alu.vcd

toolchain-check:
	mkdir -p build
	$(RISCV_GCC) -march=rv32i -mabi=ilp32 -c sw/asm/alu_smoke.S -o build/alu_smoke.o
	$(RISCV_OBJDUMP) -dr build/alu_smoke.o

test: lint sim-alu formal-alu

clean:
	rm -rf build
