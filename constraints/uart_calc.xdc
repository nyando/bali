# FPGA Configuration I/O Options
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

# 100 MHz clock
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports {clk}]

# UART receiver port
set_property -dict {PACKAGE_PIN A9 IOSTANDARD LVCMOS33} [get_ports {uart_in}]

# UART transmitter port
set_property -dict {PACKAGE_PIN D10 IOSTANDARD LVCMOS33} [get_ports {uart_out}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {debug_out}]

# LED state indicator
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33} [get_ports {state[0]}]
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports {state[1]}]