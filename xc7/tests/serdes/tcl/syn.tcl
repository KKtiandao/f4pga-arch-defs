create_project -force -name $env(PROJECT_NAME) -part xc7a35tcpg236-1

read_verilog ../$env(PROJECT_NAME).v

synth_design -top top

report_timing_summary -file top_timing_synth.rpt
report_utilization -hierarchical -file top_utilization_hierarchical_synth.rpt
report_utilization -file top_utilization_synth.rpt

write_edif -force ../$env(PROJECT_NAME).edif
