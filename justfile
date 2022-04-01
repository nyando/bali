# HW programming parameters (use this for programming the FPGA)
BOARD_NAME  := "xc7a35ticsg324-1L"
DEVICE_NAME := "Digilent/210319AB5574A"

# constraint files and TCL build scripts
SCRIPTS_DIR := "./scripts"

# get all design and testbench files
SV_SOURCES := `echo $(find ./design -name "*.sv")`
SV_TESTMOD := "./tests/test_cpu_prog.sv"
SV_SIMS    := `echo $(find ./tests -name "*.sv")`

# additional arguments to pass to compiler
SV_OPTS := "--incr"

# list design or test module files
list dir:
    @find {{dir}} -name "*.sv" -printf "%f\n" | sed -e "s/.sv//g"

# compile design sources using Vivado
compile:
    xvlog --sv {{SV_OPTS}} {{SV_SOURCES}}

# compile testbench sources using Vivado
simcompile: compile
    xvlog --sv {{SV_OPTS}} {{SV_SIMS}}

# elaborate source files with testbench SIM_MODULE as top-level module
elaborate SIM_MODULE: simcompile
    xelab --debug all -top {{SIM_MODULE}} -snapshot {{SIM_MODULE}}_snapshot

# run simulation with testbench SIM_MODULE as top-level module
simulate SIM_MODULE:
    just elaborate {{SIM_MODULE}}
    xsim {{SIM_MODULE}}_snapshot -R

# run simulation and start Vivado graphical application
waveform SIM_MODULE:
    just elaborate {{SIM_MODULE}}
    xsim {{SIM_MODULE}}_snapshot --tclbatch {{SCRIPTS_DIR}}/xsim_cfg.tcl
    xsim --gui {{SIM_MODULE}}_snapshot.wdb

# run program test
progtest SIM_MODULE:
    xvlog --sv {{SV_OPTS}} {{SV_SOURCES}} {{SV_TESTMOD}}
    xvlog --sv {{SV_OPTS}} {{SV_SIMS}}
    xelab --debug all -top {{SIM_MODULE}} -snapshot {{SIM_MODULE}}_snapshot
    xsim {{SIM_MODULE}}_snapshot --tclbatch {{SCRIPTS_DIR}}/xsim_cfg.tcl
    xsim --gui {{SIM_MODULE}}_snapshot.wdb

# create bitstream with MODULE_NAME as top-level module
bitstream MODULE_NAME:
    vivado -mode batch -source {{SCRIPTS_DIR}}/create_bitstream.tcl -tclargs {{MODULE_NAME}} {{BOARD_NAME}}

# write generated bitstream to FPGA
program MODULE_NAME:
    just bitstream {{MODULE_NAME}}
    vivado -mode batch -source {{SCRIPTS_DIR}}/program_fpga.tcl -tclargs {{MODULE_NAME}} {{DEVICE_NAME}}

# clean simulation and bitstream generation files
clean:
    rm -rf ./output
    rm -rf ./.Xil
    rm -f ./usage_statistics_webtalk.*
    rm -rf ./xsim.dir
    rm -rf ./.Xil
    rm -f ./*_snapshot.wdb
    rm -f ./*.jou
    rm -f ./*.log
    rm -f ./*.pb
    rm -f ./*.zip

