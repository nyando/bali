#######################################################################################################################
# program_fpga - Program an FPGA device via the Vivado hardware manager.
# args:
#  - program_path: Path to the bitstream file (including the filename) with which to program the FPGA.
#  - device_id: Device descriptor in the hardware manager.
#######################################################################################################################

# open and connect to hardware manager
set module_name [lindex $argv 0]
set device_id [lindex $argv 1]

# set desired device to active
open_hw_manager
connect_hw_server -url localhost:3121
current_hw_target [get_hw_targets */$device_id]
open_hw_target

# program and refresh
set device_name [lindex [get_hw_devices] 0]
current_hw_device $device_name
refresh_hw_device -update_hw_probes false $device_name
set_property PROGRAM.FILE "./output/$module_name.bit" $device_name
program_hw_devices $device_name
refresh_hw_device $device_name