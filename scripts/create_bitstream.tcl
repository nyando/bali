#######################################################################################################################
# create_bitstream: Given set of design sources and a constraints file, create bitstream for programming onto an FPGA.
# args:
#  - module_name: Name of top-level module to build, should match module's project subdirectory and constraints file.
#  - part_id: ID of FPGA board to program.
#######################################################################################################################

proc glob-r {{dir .} args} {
    set res {}
    foreach i [lsort [glob -nocomplain -dir $dir *]] {
        if {[file isdirectory $i]} {
            eval [list lappend res] [eval [linsert $args 0 glob-r $i]]
        } else {
            if {[llength $args]} {
                foreach arg $args {
                    if {[string match $arg $i]} {
                        lappend res $i
                        break
                    }
                }
            } else {
                lappend res $i
            }
        }
    }
    return $res
}

# define output directory
set output_dir ./output
set module_name [lindex $argv 0]
set part_id [lindex $argv 1]
file mkdir $output_dir

# setup design sources, constraints
read_verilog -sv [ glob-r ./design *.sv ]
read_xdc ./constraints/$module_name.xdc

# run synthesis
synth_design -top $module_name -part $part_id
write_checkpoint -force $output_dir/post_synth.dcp
report_timing_summary -file $output_dir/post_synth_timing_summary.rpt
report_utilization -file $output_dir/post_synth_util.rpt

# run logic optimization
opt_design
place_design
report_clock_utilization -file $output_dir/clock_util.rpt
write_checkpoint -force $output_dir/post_place.dcp
report_utilization -file $output_dir/post_place_util.rpt
report_timing_summary -file $output_dir/post_place_timing_summary.rpt

# run routing, report, save netlist
route_design
write_checkpoint -force $output_dir/post_route.dcp
report_route_status -file $output_dir/post_route_status.rpt
report_timing_summary -file $output_dir/post_route_timing_summary.rpt
report_power -file $output_dir/post_route_power.rpt
report_drc -file $output_dir/post_imp.drc.rpt
write_verilog -force $output_dir/$module_name.v -mode timesim -sdf_anno true

# generate bitstream
write_bitstream -force $output_dir/$module_name.bit
