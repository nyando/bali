# FPGA Configuration I/O Options
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

# 100 MHz clock
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports {clk}]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk }];

# UART receiver port
set_property -dict {PACKAGE_PIN A9 IOSTANDARD LVCMOS33} [get_ports {rx}]

# UART transmitter port
set_property -dict {PACKAGE_PIN D10 IOSTANDARD LVCMOS33} [get_ports {tx}]

# reset button
set_property -dict {PACKAGE_PIN D9 IOSTANDARD LVCMOS33} [get_ports {rst}]; 

# executing LED
set_property -dict { PACKAGE_PIN G6 IOSTANDARD LVCMOS33 } [get_ports { exec[0] }];
set_property -dict { PACKAGE_PIN G3 IOSTANDARD LVCMOS33 } [get_ports { exec[1] }];

# LEDs to indicate current progmem address
#set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33} [get_ports {addr[0]}]
#set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports {addr[1]}]
#set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports {addr[2]}]
#set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {addr[3]}]
#set_property -dict {PACKAGE_PIN F6 IOSTANDARD LVCMOS33} [get_ports {addr[4]}]
#set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS33} [get_ports {addr[5]}]
#set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {addr[6]}]
#set_property -dict {PACKAGE_PIN H6 IOSTANDARD LVCMOS33} [get_ports {addr[7]}]