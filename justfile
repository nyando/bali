# HW programming parameters (use this for programming the FPGA)
BOARD_NAME := "xc7a35ticsg324-1L"
DEVICE_NAME := "Digilent/210319AB5574A"

# project directories
export SRC_DIR := "./design"
export SIM_DIR := "./tests"

# constraint files and TCL build scripts
SCRIPTS_DIR := "./scripts"

# get all design and testbench files
SV_SOURCES := `echo $(find $SRC_DIR -name "*.sv")`
SV_SIMS := `echo $(find $SIM_DIR -name "*.sv")`

# additional arguments to pass to compiler
SV_OPTS := "--incr"

compile:
    xvlog --sv {{SV_OPTS}} {{SV_SOURCES}}

simcompile: compile
    xvlog --sv {{SV_OPTS}} {{SV_SIMS}}

elaborate SIM_MODULE: simcompile
    xelab --debug all -top {{SIM_MODULE}} -snapshot {{SIM_MODULE}}_snapshot

simulate SIM_MODULE:
    just elaborate {{SIM_MODULE}}
    xsim {{SIM_MODULE}}_snapshot -R

waveform SIM_MODULE:
    just elaborate {{SIM_MODULE}}
    xsim {{SIM_MODULE}}_snapshot --tclbatch {{SCRIPTS_DIR}}/xsim_cfg.tcl
    xsim --gui {{SIM_MODULE}}_snapshot.wdb

bitstream MODULE_NAME:
    vivado -mode batch -source {{SCRIPTS_DIR}}/create_bitstream.tcl -tclargs {{MODULE_NAME}} {{BOARD_NAME}}

program MODULE_NAME:
    just bitstream {{MODULE_NAME}}
    vivado -mode batch -source {{SCRIPTS_DIR}}/program_fpga.tcl -tclargs {{MODULE_NAME}} {{DEVICE_NAME}}

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

