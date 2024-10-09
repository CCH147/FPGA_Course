set_property IOSTANDARD LVCMOS25 [get_ports clk]
set_property PACKAGE_PIN Y9 [get_ports clk]

set_property -dict {PACKAGE_PIN F22 IOSTANDARD LVCMOS25}   [get_ports {nRst}]


set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS25}   [get_ports {up_counter[0]}]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS25}   [get_ports {up_counter[1]}]
set_property -dict {PACKAGE_PIN W22 IOSTANDARD LVCMOS25}   [get_ports {up_counter[2]}]
set_property -dict {PACKAGE_PIN V22 IOSTANDARD LVCMOS25}   [get_ports {up_counter[3]}]

set_property -dict {PACKAGE_PIN U21 IOSTANDARD LVCMOS25}   [get_ports {down_counter[3]}]
set_property -dict {PACKAGE_PIN U22 IOSTANDARD LVCMOS25}   [get_ports {down_counter[2]}]
set_property -dict {PACKAGE_PIN T21 IOSTANDARD LVCMOS25}   [get_ports {down_counter[1]}]
set_property -dict {PACKAGE_PIN T22 IOSTANDARD LVCMOS25}   [get_ports {down_counter[0]}]