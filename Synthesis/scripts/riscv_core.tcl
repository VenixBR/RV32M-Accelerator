

# Last update: 2024/05/08

#-----------------------------------------------------------------------------
# General Comments
#-----------------------------------------------------------------------------
# puts "  "
# puts "  "
# puts "  "
# puts "  "

set_db super_thread_servers localhost
set_db max_cpus_per_server 8
gui_show 


#-----------------------------------------------------------------------------
# Main Custom Variables Design Dependent (set local)
#-----------------------------------------------------------------------------
set PROJECT_DIR $env(PROJECT_DIR)
set TECH_DIR $env(TECH_DIR)
set DESIGNS $env(DESIGNS)
set HDL_NAME $env(HDL_NAME)
set INTERCONNECT_MODE ple
set OP_CORNER $env(OP_CORNER)
set HDL_LANG $env(HDL_LANG)
set USE_VCD_POWER_ANALYSIS 1

set freq_mhz $env(FREQ_MHZ)

#-----------------------------------------------------------------------------
# MAIN Custom Variables to be used in SDC (constraints file)
#-----------------------------------------------------------------------------
set MAIN_CLOCK_NAME clk
set MAIN_RST_NAME rst_n
set BEST_LIB_OPERATING_CONDITION PVT_1P32V_0C
set WORST_LIB_OPERATING_CONDITION PVT_0P9V_125C
set period_clk [format "%.2f" [expr 1000.0 / $freq_mhz]] ;# (100 ns = 10 MHz) (10 ns = 100 MHz) (2 ns = 500 MHz) (1 ns = 1 GHz)
set clk_uncertainty 0.05 ;# ns (“a guess”)
set clk_latency 0.10 ;# ns (“a guess”)
set in_delay 0.30 ;# ns
set out_delay 0.30;#ns 
set out_load 0.045 ;#pF 
set slew "146 164 264 252" ;#minimum rise, minimum fall, maximum rise and maximum fall 
set slew_min_rise 0.146 ;# ns
set slew_min_fall 0.164 ;# ns
set slew_max_rise 0.264 ;# ns
set slew_max_fall 0.252 ;# ns
#
set WORST_LIST {slow_vdd1v0_basicCells.lib} 
set BEST_LIST {fast_vdd1v2_basicCells.lib} 
set LEF_LIST {gsclib045_tech.lef gsclib045_macro.lef}
set WORST_CAP_LIST ${TECH_DIR}/gpdk045_v_6_0/soce/gpdk045.basic.CapTbl
set QRC_LIST ${TECH_DIR}/gpdk045_v_6_0/qrc/rcworst/qrcTechFile



#-----------------------------------------------------------------------------
# Load Path File
#-----------------------------------------------------------------------------
source ${PROJECT_DIR}/Synthesis/scripts/common/path.tcl

#-----------------------------------------------------------------------------
# Load Tech File
#-----------------------------------------------------------------------------
source ${SCRIPT_DIR}/common/tech.tcl

#-----------------------------------------------------------------------------
# Analyze RTL source (manually set)
#-----------------------------------------------------------------------------
set_db init_hdl_search_path ${FRONTEND_DIR}

## MODEL FOR REPLACING:

## read_hdl -language ${HDL_LANG} filename_1
## read_hdl -language ${HDL_LANG} filename_2
## ...
## read_hdl -language ${HDL_LANG} filename_3

read_hdl -language v2001 -f "${HDL_DIR}/filelist_genus.flist"




#-----------------------------------------------------------------------------
# Elaborate Design
#-----------------------------------------------------------------------------
elaborate ${HDL_NAME}
set_top_module ${HDL_NAME}
check_design -unresolved ${HDL_NAME}
get_db current_design
check_library


#-----------------------------------------------------------------------------
# Constraints
#-----------------------------------------------------------------------------
read_sdc ${PROJECT_DIR}/Synthesis/constraints/${HDL_NAME}.sdc
report timing -lint
report_timing -lint > ${RPT_DIR}/${freq_mhz}_MHz/${OP_CORNER}/${HDL_NAME}_timing_lint.rpt

#-----------------------------------------------------------------------------
# Pos "Elaborate" Attributes (manually set)
#-----------------------------------------------------------------------------
set_db auto_ungroup both ;# (none|both) ungrouping will not be performed

# set_db hinst:riscv_core/u_mul .ungroup_ok false
# set_db hinst:riscv_core/u_div .ungroup_ok false

## Layout Error Solved
# foreach lc [get_db base_cells -if {.site == "*CoreSiteDouble*"}] {
#   get_db $lc .dont_use
#   set_db $lc .dont_use true
# }


#-----------------------------------------------------------------------------
# Generic optimization (technology independent)
#-----------------------------------------------------------------------------
syn_generic ${HDL_NAME} 

#-----------------------------------------------------------------------------
# Agressively optimization (area, timing, power) and mapping
#-----------------------------------------------------------------------------
syn_map ${HDL_NAME} 
get_db insts .base_cell.name -u ;# List all cell names used in the current design.


#-----------------------------------------------------------------------------
# Preparing and generating output data (reports, verilog netlist)
#-----------------------------------------------------------------------------
report_design_rules ;# > ${RPT_DIR}/${HDL_NAME}_drc.rpt
report_area -detail > ${RPT_DIR}/${freq_mhz}_MHz/${OP_CORNER}/${HDL_NAME}_area_detail.rpt
report_timing > ${RPT_DIR}/${freq_mhz}_MHz/${OP_CORNER}/${HDL_NAME}_timing.rpt
report_gates > ${RPT_DIR}/${freq_mhz}_MHz/${OP_CORNER}/${HDL_NAME}_gates.rpt
report_qor > ${RPT_DIR}/${freq_mhz}_MHz/${OP_CORNER}/${HDL_NAME}_qor.rpt
report_power -unit uW > ${RPT_DIR}/${freq_mhz}_MHz/${OP_CORNER}/${HDL_NAME}_power_no_vcd.rpt
report_area > ${RPT_DIR}/${freq_mhz}_MHz/${OP_CORNER}/${HDL_NAME}_area.rpt
report_hierarchy > ${RPT_DIR}/${freq_mhz}_MHz/${OP_CORNER}/${HDL_NAME}_hierarchy.rpt

# set fp [open "${RPT_DIR}/lp_computed_probability_a1_no_vcd.rpt" "w"]
# puts $fp [get_db hnet:a_i[1] .lp_computed_probability]
# close $fp

# set fp [open "${RPT_DIR}/lp_computed_probability_sum7_no_vcd.rpt" "w"]
# puts $fp [get_db hnet:sum_o[7] .lp_computed_probability]
# close $fp

# set fp [open "${RPT_DIR}/lp_computed_toggle_rate_a1_no_vcd.rpt" "w"]
# puts $fp [get_db hnet:a_i[1] .lp_computed_toggle_rate]
# close $fp

# set fp [open "${RPT_DIR}/lp_computed_toggle_rate_sum7_no_vcd.rpt" "w"]
# puts $fp [get_db hnet:sum_o[7] .lp_computed_toggle_rate]
# close $fp

# source ../scripts/common/sdf_width_wa.etf
# write_sdf -edge check_edge -setuphold merge_always -nonegchecks -recrem merge_always -version 3.0 -design ${HDL_NAME}  > ${DEV_DIR}/${freq_mhz}_MHz/${OP_CORNER}/${HDL_NAME}.sdf
# write_hdl ${HDL_NAME} > ${DEV_DIR}/${freq_mhz}_MHz/${OP_CORNER}/${HDL_NAME}.v


#-----------------------------------------------------------------------------
# Power Report With VCD
#-----------------------------------------------------------------------------
# if { $USE_VCD_POWER_ANALYSIS } {
#     read_stimulus -allow_n_nets -format vcd -file ../../../frontend/vcd_${freq_mhz}MHz_pre_layout_rx_parity_bit.vcd
#     set_db power_engine joules ;# <joules or legacy>
#     report_sdb_annotation ;# -show_details unasserted -inputs
#     report_power -unit uW > ${RPT_DIR}/${freq_mhz}_MHz/${HDL_NAME}_power_vcd_${freq_mhz}MHz_pre_layout_rx_parity_bit.rpt

#     read_stimulus -allow_n_nets -format vcd -file ../../../frontend/vcd_${freq_mhz}MHz_pre_layout_rx_crc_seq.vcd
#     set_db power_engine joules ;# <joules or legacy>
#     report_sdb_annotation ;# -show_details unasserted -inputs
#     report_power -unit uW > ${RPT_DIR}/${freq_mhz}_MHz/${HDL_NAME}_power_vcd_${freq_mhz}MHz_pre_layout_rx_crc_seq.rpt

# }







