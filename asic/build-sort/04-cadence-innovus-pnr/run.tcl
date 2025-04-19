#=========================================================================
# 04-cadence-innovus-pnr/run.tcl
#=========================================================================

#-------------------------------------------------------------------------
# Initial Setup
#-------------------------------------------------------------------------

set init_mmmc_file "setup-timing.tcl"
set init_verilog   "../02-synopsys-dc-synth/post-synth.v"
set init_top_cell  "SortUnitStruct"
set init_lef_file  "$env(ECE6745_STDCELLS)/rtk-tech.lef $env(ECE6745_STDCELLS)/stdcells.lef"
set init_gnd_net   "VSS"
set init_pwr_net   "VDD"

init_design

setDesignMode -process 45

setDelayCalMode -SIAware false
setOptMode -usefulSkew false

setOptMode -holdTargetSlack 0.010
setOptMode -holdFixingCells {
  BUF_X1 BUF_X1 BUF_X2 BUF_X4 BUF_X8 BUF_X16 BUF_X32
}

#-------------------------------------------------------------------------
# Floorplanning
#-------------------------------------------------------------------------

floorPlan -r 1.0 0.70 4.0 4.0 4.0 4.0

#-------------------------------------------------------------------------
# Placement
#-------------------------------------------------------------------------

place_opt_design
addTieHiLo -cell "LOGIC1_X1 LOGIC0_X1"
assignIoPins -pin *

#-------------------------------------------------------------------------
# Power Routing
#-------------------------------------------------------------------------

globalNetConnect VDD -type pgpin -pin VDD -all -verbose
globalNetConnect VSS -type pgpin -pin VSS -all -verbose

globalNetConnect VDD -type tiehi -pin VDD -all -verbose
globalNetConnect VSS -type tielo -pin VSS -all -verbose

sroute -nets {VDD VSS}

addRing \
  -nets {VDD VSS} -width 0.8 -spacing 0.8 \
  -layer [list top 9 bottom 9 left 8 right 8]

addStripe \
  -nets {VSS VDD} -layer 9 -direction horizontal \
  -width 0.8 -spacing 4.8 \
  -set_to_set_distance 11.2 -start_offset 2.4

addStripe \
  -nets {VSS VDD} -layer 8 -direction vertical \
  -width 0.8 -spacing 4.8 \
  -set_to_set_distance 11.2 -start_offset 2.4

#-------------------------------------------------------------------------
# Clock-Tree Synthesis
#-------------------------------------------------------------------------

create_ccopt_clock_tree_spec
set_ccopt_property update_io_latency false
clock_opt_design

optDesign -postCTS -setup
optDesign -postCTS -hold

#-------------------------------------------------------------------------
# Routing
#-------------------------------------------------------------------------

routeDesign

optDesign -postRoute -setup
optDesign -postRoute -hold
optDesign -postRoute -drv

extractRC

#-------------------------------------------------------------------------
# Finishing
#-------------------------------------------------------------------------

setFillerMode -core {FILLCELL_X4 FILLCELL_X2 FILLCELL_X1}
addFiller
 
verifyConnectivity
verify_drc

#-------------------------------------------------------------------------
# Outputs
#-------------------------------------------------------------------------

saveDesign  post-pnr.enc
saveNetlist post-pnr.v
 
rcOut -rc_corner typical -spef post-pnr.spef
write_sdf post-pnr.sdf
 
streamOut post-pnr.gds \
  -merge "$env(ECE6745_STDCELLS)/stdcells.gds" \
  -mapFile "$env(ECE6745_STDCELLS)/rtk-stream-out.map"
 
report_timing -late  -path_type full_clock -net > timing-setup.rpt
report_timing -early -path_type full_clock -net > timing-hold.rpt
report_area > area.rpt

exit
