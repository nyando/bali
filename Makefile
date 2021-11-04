##
## Bali Makefile
##

# use powershell on windows
ifeq ($(OS), Windows_NT)
  SHELL := powershell.exe
  .SHELLFLAGS := -NoProfile -Command
endif

# top-level simulation module (DO NOT USE THIS FOR PROGRAMMING THE FPGA)
TOP_MODULE := test_uart

# HW programming parameters (use this for programming the FPGA)
MODULE_NAME := uart_led
BOARD_NAME := xc7a35ticsg324-1L
DEVICE_NAME := Digilent/210319AB5574A

# project directories
SRC_DIR     := ./design
SIM_DIR     := ./tests
CONSTRS_DIR := ./constraints
SCRIPTS_DIR := ./scripts

SV_SOURCES := \
	$(SRC_DIR)/alu.sv \
	$(SRC_DIR)/clkdiv.sv \
	$(SRC_DIR)/led_mapper.sv \
	$(SRC_DIR)/uart_echo.sv \
	$(SRC_DIR)/uart_rx.sv \
	$(SRC_DIR)/uart_led.sv \
	$(SRC_DIR)/uart_tx.sv \

SV_SIMS := \
	$(SIM_DIR)/alu_test.sv \
	$(SIM_DIR)/sim_clk.sv \
	$(SIM_DIR)/test_uart.sv \

SV_OPTS := \
	--incr \
	--relax \

compile: $(SV_SOURCES)
	echo "### COMPILING SOURCE FILES ###"
	xvlog --sv $(SV_OPTS) $(SV_SOURCES)

compile_sim: compile
	echo "### COMPILING SIMULATION FILES ###"
	xvlog --sv $(SV_OPTS) $(SV_SIMS)

elaborate: compile_sim
	xelab --debug all -top $(TOP_MODULE) -snapshot $(TOP_MODULE)_snapshot

simulate: elaborate
	xsim $(TOP_MODULE)_snapshot -R

simulate_gui: elaborate
	xsim $(TOP_MODULE)_snapshot --tclbatch $(SCRIPTS_DIR)/xsim_cfg.tcl
	xsim --gui $(TOP_MODULE)_snapshot.wdb

bitstream:
	vivado -mode batch -source $(SCRIPTS_DIR)/create_bitstream.tcl -tclargs "$(MODULE_NAME)" "$(BOARD_NAME)"

program: bitstream
	vivado -mode batch -source $(SCRIPTS_DIR)/program_fpga.tcl -tclargs "$(MODULE_NAME)" "$(DEVICE_NAME)"

clean_bitstream:
	rm -r ./output
	rm -r ./.Xil
	rm ./usage_statistics_webtalk.*
	rm ./*.jou
	rm ./*.log

clean_simulation:
	rm -r ./xsim.dir
	rm -r ./.Xil
	rm ./$(TOP_MODULE)_snapshot.wdb
	rm ./*.jou
	rm ./*.log
	rm ./*.pb
