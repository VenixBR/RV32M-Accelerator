## Defining Variables
DESIGNS := uart_top
USER := mendes202020178
PROJECT_DIR := /home/aoc/$(USER)/psdi/trabalho_final/$(DESIGNS)
BACKEND_DIR := $(PROJECT_DIR)/backend
TECH_DIR := /home/tools/design_kits/psdi/GPDK045
HDL_NAME := $(DESIGNS)

FREQ_MHZ ?= 500
export FREQ_MHZ

## Run Logical Synthesis
run_synth:
	./run_first.tcl

## Compile SDF
compile_sdf:
	cd $(PROJECT_DIR)/backend/synthesis/work && \
	xmsdfc -iocondsort -compile $(PROJECT_DIR)/backend/synthesis/deliverables/$(FREQ_MHZ)_MHz/$(DESIGNS)_worst.sdf

## Simulation
sim:
	cd $(PROJECT_DIR)/backend/synthesis/work && \
	xrun -clean && \
	xrun $(PROJECT_DIR)/frontend/*.sv -sv -timescale '1ns/1ps' -access +rwc -gui

## Simulation with SDF notation
sim_pos_syn:
	cd $(PROJECT_DIR)/backend/synthesis/work && \
	xrun -clean && \
	xrun -iocondsort $(TECH_DIR)/gsclib045_all_v4.4/gsclib045/verilog/slow_vdd1v0_basicCells.v $(PROJECT_DIR)/backend/synthesis/deliverables/$(FREQ_MHZ)_MHz/$(DESIGNS).v $(PROJECT_DIR)/frontend/$(DESIGNS)_tb.sv -sv -timescale '1ns/1ps' -access +rwc -gui +define+SDFSIM

.PHONY: run_synth compile_sdf sim_pos_syn sim

