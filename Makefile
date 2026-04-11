export ROOT       = $(CURDIR)
#export DESIGN_    = multiplier_top
export DESIGN_    = divider
#export DESIGN_    = M_accelerator_wrapper
export FREQ_MHZ   ?= 355
export TECH       ?= 45
export OP_CORNER  ?= slow
export RTL_DIR    = ${ROOT}/src
       TESTS_DIR  = ${ROOT}/tb

GUI        ?= 0
TB         ?= 1
MUL        ?= 0
GUI        ?= 0
TESTS      ?= 16
FLAGS_X += -access +rwc +define+TB
FLAGS_I += -g2012 -o testbench

ifeq ($(GUI),1)
	FLAGS_X += -gui
endif

ifneq ($(TESTS),16)
	FLAGS_X += +define+TESTS_NUM=$(TESTS)
	FLAGS_I += -DTESTS_NUM=${TESTS}
endif

VERILOG_PATH = /home/tools/design_kits/cadence/GPDK045/gsclib045_all_v4.4/gsclib045/verilog/slow_vdd1v0_basicCells.v


Decoder_xcelium:
	cd ${ROOT}/synthesis/work && \
	xrun -v2001 ${RTL_DIR}/decoder.v ${TESTS_DIR}/decoder_tb.sv $(FLAGS_X); \

Mult_xcelium:
	cd ${ROOT}/synthesis/work && \
	xrun -v2001 ${RTL_DIR}/mult.v ${TESTS_DIR}/mult_tb.sv $(FLAGS_X); \

Multiplier_xcelium:
	cd ${ROOT}/synthesis/work && \
	xrun -v2001 ${RTL_DIR}/multiplier_CP.v ${RTL_DIR}/mult.v ${RTL_DIR}/multiplier_DP.v ${RTL_DIR}/multiplier_top.v ${RTL_DIR}/decoder.v ${TESTS_DIR}/multiplier_tb.sv $(FLAGS_X); \

Divider_xcelium:
	cd ${ROOT}/synthesis/work && \
	xrun -v2001 ${RTL_DIR}/divider.v ${TESTS_DIR}/divider_tb.sv $(FLAGS_X); \


Accelerator_xcelium:
	cd ${ROOT}/synthesis/work && \
	xrun -timescale 1ns/10ps -v2001 -f ${RTL_DIR}/filelists/M_accelerator_wrapper_sim.flist ${TESTS_DIR}/accelerator_tb.sv $(FLAGS_X); \

sim_pos_synth_xcelium:
	cd ${ROOT}/synthesis/work && \
	xmsdfc -iocondsort -compile $(ROOT)/synthesis/outputs/deliverables/last/M_accelerator_wrapper.sdf && \
	xrun -timescale 1ns/10ps -64bit -v200x -v93 $(VERILOG_PATH) $(ROOT)/synthesis/outputs/deliverables/last/M_accelerator_wrapper.v $(FLAGS_X) $(TESTS_DIR)/accelerator_tb.sv -sdf_cmd_file $(ROOT)/synthesis/outputs/deliverables/last/sdf_cmd_file.cmd


sim_pos_synth_no_SDF_xcelium:
	cd ${ROOT}/synthesis/work && \
	xrun -timescale 1ns/10ps -64bit -v200x -v93 $(VERILOG_PATH) $(ROOT)/synthesis/outputs/deliverables/last/M_accelerator_wrapper.v $(FLAGS_X) $(TESTS_DIR)/accelerator_tb.sv





Decoder_icarus:
	cd ${ROOT}/synthesis/work && \
	iverilog ${FLAGS_I} ${RTL_DIR}/decoder.v ${TESTS_DIR}/decoder_tb.sv && \
	vvp testbench && \
	if [ "$(GUI)" = "1" ]; then \
		gtkwave dump.vcd; \
	fi

Clock_divider_icarus:
	cd ${ROOT}/synthesis/work && \
	iverilog ${FLAGS_I} ${RTL_DIR}/clock_divider.v ${TESTS_DIR}/clock_divider_tb.sv && \
	vvp testbench && \
	if [ "$(GUI)" = "1" ]; then \
		gtkwave dump.vcd; \
	fi

Multiplier_icarus:
	cd ${ROOT}/synthesis/work && \
	iverilog ${FLAGS_I} ${RTL_DIR}/multiplier_CP.v ${RTL_DIR}/mult.v ${RTL_DIR}/multiplier_DP.v ${RTL_DIR}/multiplier_top.v ${RTL_DIR}/decoder.v ${TESTS_DIR}/multiplier_tb.sv && \
	vvp testbench && \
	if [ "$(GUI)" = "1" ]; then \
		gtkwave dump.vcd  --rcvar 'fontname_signals Monospace 12' --rcvar 'fontname_waves Monospace 12'; \
	fi

Accelerator_icarus:
	cd ${ROOT}/synthesis/work && \
	iverilog ${FLAGS_I} -f ${ROOT}/src/filelists/M_accelerator_wrapper.flist ${TESTS_DIR}/accelerator_tb.sv && \
	vvp testbench && \
	if [ "$(GUI)" = "1" ]; then \
		gtkwave dump.vcd  --rcvar 'fontname_signals Monospace 12' --rcvar 'fontname_waves Monospace 12'; \
	fi

Mult_icarus:
	cd ${ROOT}/synthesis/work && \
	iverilog -g2012 -Wall -DDEBUG -o testbench ${RTL_DIR}/mult.v ${TESTS_DIR}/mult_tb.sv && \
	vvp testbench && \
	if [ "$(GUI)" = "1" ]; then \
		gtkwave dump.vcd; \
	fi

Run_Logical_Synth:
	cd ${ROOT}/synthesis/work && \
	genus -f $(ROOT)/synthesis/scripts/synth.tcl -overwrite \