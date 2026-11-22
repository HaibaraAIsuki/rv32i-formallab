VERILATOR ?= verilator
SBY ?= sby
BASH ?= bash

.PHONY: doctor lint sim-alu formal-alu test clean

doctor:
	$(BASH) scripts/check-env.sh

lint:
	$(VERILATOR) --lint-only -Wall --top-module alu rtl/alu.sv

sim-alu:
	$(VERILATOR) --binary --timing -Wall --top-module tb_alu --Mdir build/obj_dir tb/tb_alu.sv rtl/alu.sv
	./build/obj_dir/Vtb_alu

formal-alu:
	$(SBY) -f -d build/alu_formal formal/alu.sby

test: lint sim-alu formal-alu

clean:
	rm -rf build
