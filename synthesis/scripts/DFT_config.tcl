# ---------------------------------------------------------------
# ---------------- Setting shared ports- ------------------------
# ---------------------------------------------------------------

# SI Pins (is necessary be equal to DFT_N_scans variable)
set SI_PORTS [list]
lappend SI_PORTS boot_addr_i[0]
lappend SI_PORTS boot_addr_i[1]
lappend SI_PORTS boot_addr_i[2]
lappend SI_PORTS boot_addr_i[3]
lappend SI_PORTS boot_addr_i[4]
lappend SI_PORTS boot_addr_i[5]
lappend SI_PORTS boot_addr_i[6]
lappend SI_PORTS boot_addr_i[7]
lappend SI_PORTS boot_addr_i[8]
lappend SI_PORTS boot_addr_i[9]
lappend SI_PORTS boot_addr_i[10]
lappend SI_PORTS boot_addr_i[11]
lappend SI_PORTS boot_addr_i[12]
lappend SI_PORTS boot_addr_i[13]
lappend SI_PORTS boot_addr_i[14]
lappend SI_PORTS boot_addr_i[15]
lappend SI_PORTS boot_addr_i[16]
lappend SI_PORTS boot_addr_i[17]
lappend SI_PORTS boot_addr_i[18]
lappend SI_PORTS boot_addr_i[19]
lappend SI_PORTS boot_addr_i[20]
lappend SI_PORTS boot_addr_i[21]
lappend SI_PORTS boot_addr_i[22]
lappend SI_PORTS boot_addr_i[23]
lappend SI_PORTS boot_addr_i[24]
lappend SI_PORTS boot_addr_i[25]
lappend SI_PORTS boot_addr_i[26]
lappend SI_PORTS boot_addr_i[27]
lappend SI_PORTS boot_addr_i[28]
lappend SI_PORTS boot_addr_i[29]
lappend SI_PORTS boot_addr_i[30]
lappend SI_PORTS boot_addr_i[31]
lappend SI_PORTS mtvec_addr_i[0]
lappend SI_PORTS mtvec_addr_i[1]
lappend SI_PORTS mtvec_addr_i[2]
lappend SI_PORTS mtvec_addr_i[3]
lappend SI_PORTS mtvec_addr_i[4]
lappend SI_PORTS mtvec_addr_i[5]
lappend SI_PORTS mtvec_addr_i[6]
lappend SI_PORTS mtvec_addr_i[7]
lappend SI_PORTS mtvec_addr_i[8]
lappend SI_PORTS mtvec_addr_i[9]

# SO Pins (is necessary be equal to DFT_N_scans variable)
set SO_PORTS [list]
lappend SO_PORTS data_addr_o[0]
lappend SO_PORTS data_addr_o[1]
lappend SO_PORTS data_addr_o[2]
lappend SO_PORTS data_addr_o[3]
lappend SO_PORTS data_addr_o[4]
lappend SO_PORTS data_addr_o[5]
lappend SO_PORTS data_addr_o[6]
lappend SO_PORTS data_addr_o[7]
lappend SO_PORTS data_addr_o[8]
lappend SO_PORTS data_addr_o[9]
lappend SO_PORTS data_addr_o[10]
lappend SO_PORTS data_addr_o[11]
lappend SO_PORTS data_addr_o[12]
lappend SO_PORTS data_addr_o[13]
lappend SO_PORTS data_addr_o[14]
lappend SO_PORTS data_addr_o[15]
lappend SO_PORTS data_addr_o[16]
lappend SO_PORTS data_addr_o[17]
lappend SO_PORTS data_addr_o[18]
lappend SO_PORTS data_addr_o[19]
lappend SO_PORTS data_addr_o[20]
lappend SO_PORTS data_addr_o[21]
lappend SO_PORTS data_addr_o[22]
lappend SO_PORTS data_addr_o[23]
lappend SO_PORTS data_addr_o[24]
lappend SO_PORTS data_addr_o[25]
lappend SO_PORTS data_addr_o[26]
lappend SO_PORTS data_addr_o[27]
lappend SO_PORTS data_addr_o[28]
lappend SO_PORTS data_addr_o[29]
lappend SO_PORTS data_addr_o[30]
lappend SO_PORTS data_addr_o[31]
lappend SO_PORTS instr_addr_o[0]
lappend SO_PORTS instr_addr_o[1]
lappend SO_PORTS instr_addr_o[2]
lappend SO_PORTS instr_addr_o[3]
lappend SO_PORTS instr_addr_o[4]
lappend SO_PORTS instr_addr_o[5]
lappend SO_PORTS instr_addr_o[6]
lappend SO_PORTS instr_addr_o[7]
lappend SO_PORTS instr_addr_o[8]
lappend SO_PORTS instr_addr_o[9]

set TEST_MODE_PORT scan_cg_en_i ;          # Test Mode
set SCAN_ENABLE_PORT instr_rvalid_i ;      # Scan Enable
set RESET_PORT rst_ni ;                    # Reset
set COMPRESSION_ENABLE_PORT data_gnt_i ;   # Compression Enable
set CLOCK_GATE_ENABLE_PORT data_rvalid_i ; # Clock Gate Enable
set MASK_ENABLE_PORT debug_req_i ;         # Mask Enable
set MASK_LOAD_PORT fetch_enable_i ;        # Mask Load


# ---------------------------------------------------------------
# ---------------- Appling the settings -------------------------
# ---------------------------------------------------------------

# Convert non scan flops to scan flops
set_db merge_non_scan_to_scan_flops true

# Select the scan style
set_db dft_scan_style muxed_scan

# Configuration
set_db dft_prefix DFT_
set_db dft_identify_top_level_test_clocks true
#set_db [current_design] .dft_identify_test_signals true 
set_db [current_design] .dft_scan_map_mode tdrc_pass
set_db [current_design] .dft_connect_shift_enable_during_mapping tie_off ; # Conecta pino ScanEnable do FF a 0. 
set_db [current_design] .dft_connect_scan_data_pins_during_mapping loopback ; # Conecta a Saída Q do FF a Entrada ScanIn.
set_db [current_design] .dft_scan_output_preference auto 
set_db [current_design] .dft_lockup_element_type preferred_level_sensitive 
set_db [current_design] .dft_mix_clock_edges_in_scan_chains true  ;# Permite Multiplos domínios de clock na mesma scan
set_db dft_dont_merge_multibit_lockup false

# PINS AND SCAN DEFINITION

# Clock signal configuration
set_db dft_clock_waveform_divide_fall 100 ; #default: 100
set_db dft_clock_waveform_divide_rise 100 ; #default: 100
set_db dft_clock_waveform_divide_period 1 ; #default: 1
set_db dft_clock_waveform_rise 40 ; #default: 50
set_db dft_clock_waveform_fall 90 ; #default: 90
set_db dft_clock_waveform_period 100000 ; #default: 50000
define_test_clock -name clk_i -domain dft_clk_domain clk_i

# Define the scan enable to clock gate (test mode)
define_test_signal -function test_mode -name SCAN_CG -active high $TEST_MODE_PORT -lec_value 0 -test_only

# Define the shift enable for scan muxes
define_test_signal -function shift_enable -name SE -active high -port_bus $SCAN_ENABLE_PORT 

# Define the reset
define_test_signal -name reset_ni -ideal -function async_set_reset -active low -port_bus $RESET_PORT -shared_input -scan_shift

define_test_signal -name DFT_CG_EN -function lp_gating_enable -active high   -port_bus $CLOCK_GATE_ENABLE_PORT -shared_input

# Compression
if {$DFT_compress} {
    define_test_signal -name DFT_CE -function compression_enable -active high   -port_bus $COMPRESSION_ENABLE_PORT -shared_input
    define_test_signal -name DFT_MASK_EN -function mask_enable -active high   -port_bus $MASK_ENABLE_PORT -shared_input
    define_test_signal -name DFT_MASK_LD -function mask_load -active high   -port_bus $MASK_LOAD_PORT -shared_input

    for {set i 0} {$i < $DFT_N_scans} {incr i} {
      # define_test_signal -function compress_sdi DFT_SI[$i] -index ${i} -create_port
      # define_test_signal -function compress_sdo DFT_SO[$i] -index ${i} -create_port
      #define_test_signal -name DFT_SI[$i] -function compress_sdi -active high -lec_value 0 -test_only -port_bus [lindex $SI_PORTS $i] -shared_input
      #define_test_signal -name DFT_SO[$i] -function compress_sdo -active high -lec_value 0 -test_only -port_bus [lindex $SO_PORTS $i] -shared_output
      define_scan_chain -name SCAN_TOP[$i] -sdi [lindex $SI_PORTS $i] -sdo [lindex $SO_PORTS $i] -shift_enable SE -shared_input -shared_output
    }

    set_db dft_compression_auto_create true
    set_db dft_compression_num_scanin $DFT_N_scans
    set_db dft_compression_num_scanout $DFT_N_scans
    set_db dft_compression_decompressor_type xor
    set_db dft_compression_compressor_type xor
    set_db dft_compression_ratio $DFT_compress_ratio ; # Multiplicador pela quantidade de entradas para saber o número total de SC: 4x8 = 32
    set_db dft_compression_fullscan_support true
    set_db dft_compression_mask_support true ; # Para Compressor e decompresso do tipo XOR wide1 é ideal
    set_db dft_compression_lp_gating_support true
}  else {
    for {set i 0} { $i < $DFT_N_scans } { incr i } {
      #define_test_signal -name DFT_SI[$i] -function serial_sdi -active high -lec_value 0 -test_only -port_bus [lindex $SI_PORTS $i] -shared_input
      #define_test_signal -name DFT_SO[$i] -function serial_sdo -active high -lec_value 0 -test_only -port_bus [lindex $SO_PORTS $i] -shared_output
      # Pode criar as Scan Chains aqui ou depois quando conectar utilizar a opção "-auto_create_chains"
      define_scan_chain -name SCAN_TOP[$i] -sdi [lindex $SI_PORTS $i] -sdo [lindex $SO_PORTS $i] -shift_enable SE -shared_input -shared_output
    }
  }

#set_db dft_apply_sdc_constraints true
set_db dft_auto_identify_shift_register true
set_db dft_identify_shared_wrapper_cells true
set_db dft_shift_register_with_mbci true
set_db multibit_cells_from_different_busses true
