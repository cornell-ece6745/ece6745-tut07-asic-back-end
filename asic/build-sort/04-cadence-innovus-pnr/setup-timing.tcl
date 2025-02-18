 create_rc_corner -name typical \
    -cap_table "$env(ECE6745_STDCELLS)/rtk-typical.captable" \
    -T 25

 create_library_set -name libs_typical \
    -timing [list "$env(ECE6745_STDCELLS)/stdcells.lib"]

 create_delay_corner -name delay_default \
    -library_set libs_typical \
    -rc_corner typical

 create_constraint_mode -name constraints_default \
    -sdc_files [list ../02-synopsys-dc-synth/post-synth.sdc]

 create_analysis_view -name analysis_default \
    -constraint_mode constraints_default \
    -delay_corner delay_default

 set_analysis_view \
    -setup analysis_default \
    -hold analysis_default
