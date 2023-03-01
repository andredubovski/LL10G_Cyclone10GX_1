
namespace eval alt_mge_xcvr_atx_pll_10g {
  proc get_design_libraries {} {
    set libraries [dict create]
    dict set libraries altera_common_sv_packages   1
    dict set libraries altera_xcvr_atx_pll_a10_181 1
    dict set libraries alt_mge_xcvr_atx_pll_10g    1
    return $libraries
  }
  
  proc get_memory_files {QSYS_SIMDIR} {
    set memory_files [list]
    return $memory_files
  }
  
  proc get_common_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR} {
    set design_files [dict create]
    dict set design_files "altera_common_sv_packages::altera_xcvr_native_a10_functions_h" "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_a10_181/sim/altera_xcvr_native_a10_functions_h.sv"]\"  -work altera_common_sv_packages"
    return $design_files
  }
  
  proc get_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR} {
    set design_files [list]
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_a10_181/sim/twentynm_xcvr_avmm.sv"]\" -L altera_common_sv_packages -work altera_xcvr_atx_pll_a10_181"                                          
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_a10_181/sim/mentor/twentynm_xcvr_avmm.sv"]\" -L altera_common_sv_packages -work altera_xcvr_atx_pll_a10_181"                                   
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_a10_181/sim/alt_xcvr_resync.sv"]\" -L altera_common_sv_packages -work altera_xcvr_atx_pll_a10_181"                                             
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_a10_181/sim/alt_xcvr_arbiter.sv"]\" -L altera_common_sv_packages -work altera_xcvr_atx_pll_a10_181"                                            
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_a10_181/sim/mentor/alt_xcvr_resync.sv"]\" -L altera_common_sv_packages -work altera_xcvr_atx_pll_a10_181"                                      
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_a10_181/sim/mentor/alt_xcvr_arbiter.sv"]\" -L altera_common_sv_packages -work altera_xcvr_atx_pll_a10_181"                                     
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_a10_181/sim/a10_avmm_h.sv"]\" -L altera_common_sv_packages -work altera_xcvr_atx_pll_a10_181"                                                  
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_a10_181/sim/alt_xcvr_atx_pll_rcfg_arb.sv"]\" -L altera_common_sv_packages -work altera_xcvr_atx_pll_a10_181"                                   
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_a10_181/sim/a10_xcvr_atx_pll.sv"]\" -L altera_common_sv_packages -work altera_xcvr_atx_pll_a10_181"                                            
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_a10_181/sim/alt_xcvr_pll_embedded_debug.sv"]\" -L altera_common_sv_packages -work altera_xcvr_atx_pll_a10_181"                                 
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_a10_181/sim/alt_xcvr_pll_avmm_csr.sv"]\" -L altera_common_sv_packages -work altera_xcvr_atx_pll_a10_181"                                       
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_a10_181/sim/mentor/alt_xcvr_atx_pll_rcfg_arb.sv"]\" -L altera_common_sv_packages -work altera_xcvr_atx_pll_a10_181"                            
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_a10_181/sim/mentor/a10_xcvr_atx_pll.sv"]\" -L altera_common_sv_packages -work altera_xcvr_atx_pll_a10_181"                                     
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_a10_181/sim/mentor/alt_xcvr_pll_embedded_debug.sv"]\" -L altera_common_sv_packages -work altera_xcvr_atx_pll_a10_181"                          
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_a10_181/sim/mentor/alt_xcvr_pll_avmm_csr.sv"]\" -L altera_common_sv_packages -work altera_xcvr_atx_pll_a10_181"                                
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_a10_181/sim/alt_mge_xcvr_atx_pll_10g_altera_xcvr_atx_pll_a10_181_lszmxda.sv"]\" -L altera_common_sv_packages -work altera_xcvr_atx_pll_a10_181"
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_a10_181/sim/alt_xcvr_atx_pll_rcfg_opt_logic_lszmxda.sv"]\" -L altera_common_sv_packages -work altera_xcvr_atx_pll_a10_181"                     
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/alt_mge_xcvr_atx_pll_10g.v"]\"  -work alt_mge_xcvr_atx_pll_10g"                                                                                                           
    return $design_files
  }
  
  proc get_elab_options {SIMULATOR_TOOL_BITNESS} {
    set ELAB_OPTIONS ""
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ELAB_OPTIONS
  }
  
  
  proc get_sim_options {SIMULATOR_TOOL_BITNESS} {
    set SIM_OPTIONS ""
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $SIM_OPTIONS
  }
  
  
  proc get_env_variables {SIMULATOR_TOOL_BITNESS} {
    set ENV_VARIABLES [dict create]
    set LD_LIBRARY_PATH [dict create]
    dict set ENV_VARIABLES "LD_LIBRARY_PATH" $LD_LIBRARY_PATH
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ENV_VARIABLES
  }
  
  
  proc normalize_path {FILEPATH} {
      if {[catch { package require fileutil } err]} { 
          return $FILEPATH 
      } 
      set path [fileutil::lexnormalize [file join [pwd] $FILEPATH]]  
      if {[file pathtype $FILEPATH] eq "relative"} { 
          set path [fileutil::relative [pwd] $path] 
      } 
      return $path 
  } 
}
