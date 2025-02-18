#=========================================================================
# 06-synopsys-pt-pwr/run.tcl
#=========================================================================

#-------------------------------------------------------------------------
# Initial setup
#-------------------------------------------------------------------------

set_app_var target_library "$env(ECE6745_STDCELLS)/stdcells.db"
set_app_var link_library   "* $env(ECE6745_STDCELLS)/stdcells.db"

set_app_var power_enable_analysis true

#-------------------------------------------------------------------------
# Inputs
#-------------------------------------------------------------------------

read_verilog ../04-cadence-innovus-pnr/post-pnr.v
current_design SortUnitStruct
link_design

read_saif ../05-synopsys-vcs-baglsim/waves.saif -strip_path Top/DUT
read_parasitics -format spef ../04-cadence-innovus-pnr/post-pnr.spef

#-------------------------------------------------------------------------
# Timing constraints
#-------------------------------------------------------------------------

create_clock clk -name ideal_clock1 -period 0.7

#-------------------------------------------------------------------------
# Power Analysis
#-------------------------------------------------------------------------

update_power

#-------------------------------------------------------------------------
# Outputs
#-------------------------------------------------------------------------

report_power            > power-summary.rpt
report_power -hierarchy > power-detailed.rpt

exit
