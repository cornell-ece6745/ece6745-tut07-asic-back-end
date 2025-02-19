#=========================================================================
# 02-synopsys-dc-synth/run.tcl
#=========================================================================

#-------------------------------------------------------------------------
# Initial setup
#-------------------------------------------------------------------------

set_app_var target_library "$env(ECE6745_STDCELLS)/stdcells.db"
set_app_var link_library   "* $env(ECE6745_STDCELLS)/stdcells.db"

set_dont_use {
  NangateOpenCellLibrary/SDFF_X1
  NangateOpenCellLibrary/SDFF_X2
  NangateOpenCellLibrary/SDFFS_X1
  NangateOpenCellLibrary/SDFFS_X2
  NangateOpenCellLibrary/SDFFR_X1
  NangateOpenCellLibrary/SDFFR_X2
  NangateOpenCellLibrary/SDFFRS_X1
  NangateOpenCellLibrary/SDFFRS_X2
}

#-------------------------------------------------------------------------
# Inputs
#-------------------------------------------------------------------------

analyze -format sverilog $env(TOPDIR)/sim/build/SortUnitStruct__pickled.v
elaborate SortUnitStruct

#-------------------------------------------------------------------------
# Timing constraints
#-------------------------------------------------------------------------

create_clock clk -name ideal_clock1 -period 0.7

set_max_transition 0.250 SortUnitStruct

set_driving_cell -no_design_rule -lib_cell INV_X2 [all_inputs]
set_load -pin_load 7 [all_outputs]

set_input_delay -clock ideal_clock1 -max 0.050 [all_inputs -exclude_clock_ports]
set_input_delay -clock ideal_clock1 -min 0     [all_inputs -exclude_clock_ports]

set_output_delay -clock ideal_clock1 -max 0.050 [all_outputs]
set_output_delay -clock ideal_clock1 -min 0     [all_outputs]

set_max_delay 0.7 -from [all_inputs -exclude_clock_ports] -to [all_outputs]

check_timing

#-------------------------------------------------------------------------
# Synthesis
#-------------------------------------------------------------------------

check_design
compile

#-------------------------------------------------------------------------
# Outputs
#-------------------------------------------------------------------------

write -format ddc     -hierarchy -output post-synth.ddc
write -format verilog -hierarchy -output post-synth.v
write_sdc post-synth.sdc

report_timing -nets      > timing.rpt
report_area   -hierarchy > area.rpt

exit
