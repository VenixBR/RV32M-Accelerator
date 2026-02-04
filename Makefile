ROOT       = $(CURDIR)
RTL_DIR    = ${ROOT}/src
TESTS_DIR  = ${ROOT}/tb
GUI        ?= 0
TB         ?= 1
MUL        ?= 0
GUI        ?= 0
FLAGS += -access +rwc
ifeq ($(GUI),1)
	FLAGS += -gui
endif

Multiplier:
	cd ${ROOT}/Synthesis/work && \
	if [ "$(TB)" = "0" ]; then \
		xrun -v2001 ${RTL_DIR}/new_multiplier.v $(FLAGS); \
	else \
		xrun -v2001 ${RTL_DIR}/new_multiplier.v ${TESTS_DIR}/new_multiplier_tb.sv $(FLAGS) +define+CLA4x4; \
	fi

Divisor:
	cd ${ROOT}/Synthesis_div/work && \
	if [ "$(TB)" = "0" ]; then \
		xrun -v2001 ${RTL_DIR}/biriscv_divider.v $(FLAGS); \
	else \
		xrun -v2001 ${RTL_DIR}/biriscv_divider.v ${TESTS_DIR}/new_multiplier_tb.sv $(FLAGS) +define+CLA4x4; \
	fi

ControlPath:
	cd ${ROOT}/Work && \
	if [ "$(TB)" = "0" ]; then \
		xrun -v2001  ${RTL_DIR}/ControlPath.v $(FLAGS) ; \
	else \
		xrun -v2001 ${RTL_DIR}/Described_HDLs/ControlPath.v ${TESTS_DIR}/ControlPath_tb.sv $(FLAGS); \
	fi

DataPath:
	cd ${ROOT}/Work && \
	xrun -v2001 ${RTL_DIR}/Comparator.v ${RTL_DIR}/DataPath.v $(FLAGS); \

Top:
	cd ${ROOT}/Synthesis/work && \
	
	else \
		xrun -v2001 -v93 -f ${TESTS_DIR}/tb_core_icarus/filelist.flist $(FLAGS) -incdir ../../src/core/; \
	fi


Multiplier_icarus:
	cd ${ROOT}/Synthesis/work && \
	iverilog -g2012 -o testbench ${RTL_DIR}/new_multiplier.v ${TESTS_DIR}/new_multiplier_tb.sv && \
	vvp testbench && \
	gtkwave dump.vcd \

Multiplier_CP_icarus:
	cd ${ROOT}/Synthesis/work && \
	iverilog -g2012 -o testbench ${RTL_DIR}/multiplier_CP.v ${TESTS_DIR}/multiplier_CP_tb.sv && \
	vvp testbench && \
	if [ "$(GUI)" = "1" ]; then \
		gtkwave dump.vcd; \
	fi





###################################################
## BUZATTI MAKEFILE TO SYNTHESIS
###################################################
## Defining Variables
###################################################

# Design top name (Top module name and filename must be the same)
ifeq ($(MUL),0)
DESIGNS := riscv_core
else
DESIGNS := biriscv_multiplier
endif
export DESIGNS


# Username
USER := $(shell whoami)
export USER

## Hardware Description Language

## VHDL: HDL_LANG = vhdl
## SystemVerilog: HDL_LANG = sv
## Verilog: HDL_LANG = v2001 or HDL_LANG = v1995
HDL_LANG := v2001

# Validation
ifneq ($(filter $(HDL_LANG),vhdl sv v2001 v1995),$(HDL_LANG))
  $(error Valor invalido para HDL_LANG="$(HDL_LANG)". Use apenas: vhdl, sv, v2001 (default) ou v1995)
endif

export HDL_LANG

# Project directory (the top folder name should be the design name)
PROJECT_DIR := $(CURDIR)
export PROJECT_DIR

## Logic synthesis directory
ifeq ($(MUL),0)
SYNTHESIS_DIR := $(PROJECT_DIR)/Synthesis
else
SYNTHESIS_DIR := $(PROJECT_DIR)/Synthesis_mul
endif
export SYNTHESIS_DIR

## Technology directory
TECH_DIR := /home/tools/design_kits/cadence/GPDK045/
export TECH_DIR

## HDL Name
HDL_NAME := $(DESIGNS)
export HDL_NAME

## If it is not specified in Command Line, Synthesis frequency is set to 500 MHz
FREQ_MHZ ?= 500
export FREQ_MHZ

## If it is not specified in Command Line, Corner is set to WORST (there ain't no typcal)
OP_CORNER ?= WORST

# Validation
ifneq ($(filter $(OP_CORNER),WORST BEST),$(OP_CORNER))
  $(error Valor invalido para OP_CORNER="$(OP_CORNER)". Use apenas: WORST ou BEST)
endif

export OP_CORNER


## File Extension
ifeq ($(HDL_LANG),vhdl)
  FILE_EXTENSION = vhd
else ifeq ($(HDL_LANG),sv)
  FILE_EXTENSION = sv
else ifeq ($(HDL_LANG),v2001)
  FILE_EXTENSION = v
else ifeq ($(HDL_LANG),v1995)
  FILE_EXTENSION = v
endif

export FILE_EXTENSION


## DUV Scope (VHDL must be different)
ifeq ($(HDL_LANG),vhdl)
  DUV_SCOPE = :DUV
else 
  DUV_SCOPE = ${DESIGNS}_tb/DUV
endif

export DUV_SCOPE

## If you want, you can add extra arguments for Xcelium execution
## Usefull for VHDL flgas (e.g -v200x -v93)
## Values should be written as an array of strings (e.g EXTRA_ARGS="-linedebug -coverage all -input test.do")

ifeq ($(HDL_LANG),vhdl)
  EXTRA_ARGS = "-v200x -v95"
endif

EXTRA_ARGS ?=

## Run Logic Synthesis
run-synth:
	$(SYNTHESIS_DIR)/scripts/run_first.tcl

## Compile SDF
compile-sdf:
	cd $(PROJECT_DIR)/Synthesis/work && \
	xmsdfc -iocondsort  -compile $(PROJECT_DIR)/Synthesis/deliverables/$(FREQ_MHZ)_MHz/$(OP_CORNER)/$(DESIGNS).sdf

## Simulation with no GUI
sim:
	cd $(PROJECT_DIR)/frontend/work && \
	xrun -clean && \
	xrun -f filelist.txt -mess -64bit $(EXTRA_ARGS) -top ${DESIGNS}_tb -timescale '1ns/1ps' -access +rwc

## Simulation with GUI
sim-gui:
	cd $(PROJECT_DIR)/frontend/work && \
	xrun -clean && \
	xrun -f filelist.txt -mess -64bit -top ${DESIGNS}_tb -timescale '1ns/1ps' -access +rwc -gui

## Simulation with SDF notation (no GUI)
sim-pos-syn:
	@if [ "$(OP_CORNER)" = "WORST" ]; then \
	  cd "$(PROJECT_DIR)/Synthesis/work" && \
	  xrun -clean && \
	  xrun -iocondsort $(EXTRA_ARGS) -mess -64bit -noneg_tchk  \
	    "$(TECH_DIR)/gsclib045_all_v4.4/gsclib045/verilog/slow_vdd1v0_basicCells.v" \
	    "$(PROJECT_DIR)/Synthesis/deliverables/$(FREQ_MHZ)_MHz/$(OP_CORNER)/$(DESIGNS).v" \
	    "$(PROJECT_DIR)/HDL/$(DESIGNS)_tb.sv" \
	    -top ${DESIGNS}_tb -timescale 1ns/1ps -access +rwc -sdf_cmd_file ${PROJECT_DIR}/Synthesis/scripts/sdf_cmd_file.cmd; \
	fi
	@if [ "$(OP_CORNER)" = "BEST" ]; then \
	  cd "$(PROJECT_DIR)/Synthesis/work" && \
	  xrun -clean && \
	  xrun -iocondsort $(EXTRA_ARGS) -mess -64bit -noneg_tchk \
	    "$(TECH_DIR)/gsclib045_all_v4.4/gsclib045/verilog/fast_vdd1v2_basicCells.v" \
	    "$(PROJECT_DIR)/Synthesis/deliverables/$(FREQ_MHZ)_MHz/$(OP_CORNER)/$(DESIGNS).v" \
	    "$(PROJECT_DIR)/Testbenchs/$(DESIGNS)_tb.sv" \
	    -top ${DESIGNS}_tb -timescale 1ns/1ps -access +rwc -sdf_cmd_file ${PROJECT_DIR}/Synthesis/scripts/sdf_cmd_file.cmd; \
	fi

## Simulation with SDF notation (with GUI)
sim-pos-syn-gui:
	@if [ "$(OP_CORNER)" = "WORST" ]; then \
	  cd "$(PROJECT_DIR)/Synthesis/work" && \
	  xrun -clean && \
	  xrun -iocondsort $(EXTRA_ARGS) -mess -64bit -noneg_tchk \
	    "$(TECH_DIR)/gsclib045_all_v4.4/gsclib045/verilog/slow_vdd1v0_basicCells.v" \
	    "$(PROJECT_DIR)/Synthesis/deliverables/$(FREQ_MHZ)_MHz/$(OP_CORNER)/$(DESIGNS).v" \
	    "$(PROJECT_DIR)/HDL/$(DESIGNS)_tb.sv" \
	    -top ${DESIGNS}_tb  -timescale 1ns/1ps -access +rwc -gui -sdf_cmd_file ${PROJECT_DIR}/Synthesis/scripts/sdf_cmd_file.cmd; \
	fi
	@if [ "$(OP_CORNER)" = "BEST" ]; then \
	  cd "$(PROJECT_DIR)/Synthesis/work" && \
	  xrun -clean && \
	  xrun -iocondsort $(EXTRA_ARGS) -mess -64bit -noneg_tchk \
	    "$(TECH_DIR)/gsclib045_all_v4.4/gsclib045/verilog/fast_vdd1v2_basicCells.v" \
	    "$(PROJECT_DIR)/Synthesis/deliverables/$(FREQ_MHZ)_MHz/$(OP_CORNER)/$(DESIGNS).v" \
	    "$(PROJECT_DIR)/Testbenchs/$(DESIGNS)_tb.sv" \
	    -top ${DESIGNS}_tb -timescale 1ns/1ps -access +rwc -gui -sdf_cmd_file ${PROJECT_DIR}/Synthesis/scripts/sdf_cmd_file.cmd; \
	fi

.PHONY: run-synth compile-sdf sim-pos-syn sim-pos-syn-gui sim sim-gui
