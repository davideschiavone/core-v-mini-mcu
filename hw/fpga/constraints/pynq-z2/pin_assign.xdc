# Copyright 2022 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

set_property PACKAGE_PIN H16 [get_ports clk_i]
set_property PACKAGE_PIN M20 [get_ports rst_ni]
set_property PACKAGE_PIN R14 [get_ports exit_valid_o]
set_property PACKAGE_PIN P14 [get_ports exit_value_o]
set_property PACKAGE_PIN M19 [get_ports fetch_enable_i]
set_property PACKAGE_PIN T10 [get_ports jtag_tck_i]
set_property PACKAGE_PIN T11 [get_ports jtag_tdo_o]
set_property PACKAGE_PIN Y14 [get_ports jtag_tdi_i]
set_property PACKAGE_PIN W14 [get_ports jtag_tms_i]
set_property PACKAGE_PIN V16 [get_ports jtag_trst_ni]
set_property PACKAGE_PIN Y18  [get_ports uart_tx_o]
set_property PACKAGE_PIN Y19  [get_ports uart_rx_i]

set_property IOSTANDARD LVCMOS33 [get_ports clk_i]
set_property IOSTANDARD LVCMOS33 [get_ports rst_ni]
set_property IOSTANDARD LVCMOS33 [get_ports exit_valid_o]
set_property IOSTANDARD LVCMOS33 [get_ports exit_value_o]
set_property IOSTANDARD LVCMOS33 [get_ports fetch_enable_i]
set_property IOSTANDARD LVCMOS33 [get_ports jtag_tck_i]
set_property IOSTANDARD LVCMOS33 [get_ports jtag_tdo_o]
set_property IOSTANDARD LVCMOS33 [get_ports jtag_tdi_i]
set_property IOSTANDARD LVCMOS33 [get_ports jtag_tms_i]
set_property IOSTANDARD LVCMOS33 [get_ports jtag_trst_ni]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx_o]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx_i]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_tck_i_IBUF]
