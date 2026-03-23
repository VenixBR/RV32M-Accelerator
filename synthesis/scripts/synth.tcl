

# ---------------------------------------------------------------
# --------------- Setting some variables ------------------------
# ---------------------------------------------------------------


set DESIGN $env(DESIGN_)
set ROOT_DIR $env(ROOT)
set freq_mhz $env(FREQ_MHZ)
set CORNER $env(OP_CORNER)
set MULTIBIT 0
set QUIT_ON_FINISH 0

# DFT
set DFT 0
set DFT_compress 0
set DFT_N_scans 0
set DFT_compress_ratio 0

# ---------------------------------------------------------------
# ------------ Setting paths from archivers ---------------------
# ---------------------------------------------------------------

# Set the paths to search the HDL files
set_db init_hdl_search_path ${ROOT_DIR}/src


# Set the paths to search the libs and LEF files
set_db init_lib_search_path { \
  /home/tools/design_kits/cadence/GPDK045/gsclib045_svt_v4.4/gsclib045/timing \
  /home/tools/design_kits/cadence/GPDK045/giolib045_v3.3/timing \
  /home/tools/design_kits/cadence/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/ \
  /home/tools/design_kits/cadence/GPDK045/giolib045_v3.3/lef/ \
}

# Set the path to search SDC files
set SDC_SEARCH_PATH        ${ROOT_DIR}/synthesis/constraints/

# Set the path to search HDL filelist
set FILELIST_SEARCH_PATH   ${ROOT_DIR}/src/filelists/

# Set the path to save the reports and deliverables
set REPORTS_PATH           ${ROOT_DIR}/synthesis/outputs/reports/
set DELIVERABLES_PATH      ${ROOT_DIR}/synthesis/outputs/deliverables/

# Set the path to seatch CapTable file
set QRC_PATH          /home/tools/design_kits/cadence/GPDK045/gpdk045_v_6_0/qrc/



# ---------------------------------------------------------------
# ------------ Setting and load the archivers -------------------
# ---------------------------------------------------------------

# Load the TLEF and LEF files


# Load the standard cells libraries : STD, MB, IO
switch -- $CORNER {

    "slow" {
        read_libs {
            slow_vdd1v0_basicCells.lib
        }
    }

    "fast" {
        read_libs {
            fast_vdd1v2_basicCells.lib
        }

        set_db qrc_tech_file ${QRC_PATH}rcworst/qrcTechFile
    }

    "typical" {
        puts "\n\n ERROR: Do not have typical corner libraries defined."
        exit
    }

    default {
        puts "\n\n ERROR: The specified corner '$CORNER' is not valid.\n"
        exit
    }
}


read_physical -lefs {                             \
  gsclib045_tech.lef                              \
  gsclib045_macro.lef                             \
}

set_db qrc_tech_file  ${QRC_PATH}rcworst/qrcTechFile


# Load the HDL filelist
read_hdl -language v2001 -f "${FILELIST_SEARCH_PATH}${DESIGN}.flist"


# ---------------------------------------------------------------
# ------ Elabore the design and defines constraints -------------
# ---------------------------------------------------------------

# Elaborate the design
elaborate $DESIGN
check_design > "${REPORTS_PATH}${freq_mhz}/${CORNER}/${DESIGN}_check_design.rpt"

# Read constraints SDC files
# create_mode -name FUNCTIONAL -default -design ${DESIGN}
# read_sdc -mode FUNCTIONAL "${SDC_SEARCH_PATH}${DESIGN}_n22.sdc"
read_sdc "${SDC_SEARCH_PATH}constraints.sdc"
# define_cost_group -name FUNCTIONAL
report_timing -lint > "${REPORTS_PATH}${freq_mhz}/${CORNER}/${DESIGN}_constraints_summary.rpt"


# Defines the instances that could not ungroup
#set_db hinst:cv32e40p_wrapper/core_i/id_stage_i/register_file_i .ungroup_ok false

# A tcl script to make a list with MBFF cell names

if {$MULTIBIT} {
  set_db use_multibit_cells true
  set MBFF_cells ""
  foreach cell_name [get_db lib_cells */MB*] {
    regexp {(MB.*)} $cell_name temp
    set MBFF_cells "${MBFF_cells} ${temp}"
  }

  set_db [get_db lib_cells *SDF*] .avoid false

  # # Configure to do not use MBFFs in all design
  # set_db [remove_from_collection [get_db hinsts] [get_db hinst:cv32e40p_wrapper/core_i/id_stage_i/register_file_i]] .dont_use_cells $MBFF_cells
  # set_db [get_db hinsts] .dont_use_cells $MBFF_cells

  # # Configure to use MBFFs in chosen modules
  # set_db hinst:cv32e40p_wrapper/core_i/id_stage_i/register_file_i .use_cells $MBFF_cells
} else {
  set_db use_multibit_cells false
}


# Allow and dimiss the use of some cells
set_db [get_db lib_cells *CKLNQ*] .avoid false
set_db [get_db lib_cells *CKLHQ*] .avoid false


if {$DFT} {
  source ../SCRIPTS/n22ull/cv32e40p_wrapper_n22_DFT.tcl
  check_dft_rules -advanced > "${REPORTS_PATH}cv32e40p_check_dft_pre_fix.rpt"
  report_scan_registers > "${REPORTS_PATH}cv32e40p_scan_registers.rpt" 
  report_scan_setup > "${REPORTS_PATH}cv32e40p_scan_setup.rpt" 
  check_dft_pad_cfg > "${REPORTS_PATH}cv32e40p_check_dft_pads.rpt"
  fix_dft_violations -test_mode SCAN_CG -async_set -async_reset -scan_clock_pin clk_i -dont_check_dft_rules
  check_dft_rules -advanced > "${REPORTS_PATH}cv32e40p_check_dft_pos_fix.rpt"
  check_design -undriven -report_scan_pins > "${REPORTS_PATH}cv32e40p_undriven_pins.rpt"
}



# Set the effort in the synthesis stages
# set_db syn_generic_effort    high
# set_db syn_map_effort        high
# set_db syn_opt_effort        high
# set_db design_power_effort    high
# set_db optimize_constant_0_flops true
# set_db optimize_constant_1_flops true


# ---------------------------------------------------------------
# ----------------------- Synthesizes ---------------------------
# ---------------------------------------------------------------

syn_gen
syn_map 

if {$DFT} {
  if {$DFT_compress} {
    connect_scan_chains -auto_create
    compress_scan_chains -mask wide1 -ratio $DFT_compress_ratio -mask_enable DFT_MASK_EN -compression_enable DFT_CE -mask_clock clk_i -allow_shared_clocks  -mask_load DFT_MASK_LD
  } else {
    connect_scan_chains -auto_create
  }
}

#compress_scan_chains -ratio 8 -compressor xor -decompressor xor -mask wide1 -auto_create
#add_test_compression -compressor xor -decompressor xor -auto_create
#report_scan_chains

#suspend

# syn_opt

#report_scan_setup

# ---------------------------------------------------------------
# ------------------- Save the archivers ------------------------
# ---------------------------------------------------------------
set_db lp_power_unit uW 

write_hdl > "${DELIVERABLES_PATH}${freq_mhz}/${CORNER}/${DESIGN}.v"
write_sdf > "${DELIVERABLES_PATH}${freq_mhz}/${CORNER}/${DESIGN}.sdf"
report_timing > "${REPORTS_PATH}${freq_mhz}/${CORNER}/${DESIGN}_timing.rpt"
report_area > "${REPORTS_PATH}${freq_mhz}/${CORNER}/${DESIGN}_area.rpt"
report_area -detail > "${REPORTS_PATH}${freq_mhz}/${CORNER}/${DESIGN}_area_detail.rpt"
report_power -unit uW > "${REPORTS_PATH}${freq_mhz}/${CORNER}/${DESIGN}_power.rpt"
report_gates > "${REPORTS_PATH}${freq_mhz}/${CORNER}/${DESIGN}_gates.rpt"
report_hierarchy > "${REPORTS_PATH}${freq_mhz}/${CORNER}/${DESIGN}_hierarchy.rpt"

if {$MULTIBIT} {
  report_multibit_inferencing > "${REPORTS_PATH}cv32e40p_multibit.rpt"
}

if {$DFT} {
  report_scan_setup > "${REPORTS_PATH}cv32e40p_scan_setup.rpt"
  report_scan_chains > "${REPORTS_PATH}cv32e40p_scan_chains.rpt"
  write_dft_atpg_other_vendor_files -cadence > "${REPORTS_PATH}cv32e40p_assignfile.pinassign"
  write_dft_atpg -library {/home/tools/design_kits/tsmc/22/digital/TSMCHOME/digital/Front_End/verilog/tcbn22ullbwp7t40p140sg_110a/tcbn22ullbwp7t40p140sg.v /home/tools/design_kits/tsmc/22/digital/TSMCHOME/digital/Front_End/verilog/tcbn22ullbwp7t40p140mbsg_110a/tcbn22ullbwp7t40p140mbsg.v}
}

report_timing

#Delete design and quit
if {$QUIT_ON_FINISH} {
  delete_obj design:${DESIGN}
  exit
}