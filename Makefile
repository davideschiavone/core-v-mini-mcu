# Copyright EPFL contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

MAKE                       = make

# Get the absolute path
mkfile_path := $(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")

# Include the self-documenting tool
FILE=$(mkfile_path)/Makefile
include $(mkfile_path)/util/generate-makefile-help

# Setup to autogenerate python virtual environment
VENVDIR?=$(WORKDIR)/.venv
REQUIREMENTS_TXT?=$(wildcard python-requirements.txt)
include Makefile.venv

# FUSESOC and Python values (default)
FUSESOC = $(VENV)/fusesoc
PYTHON  = $(VENV)/python

# Project options are based on the app to be build (default - hello_world)
PROJECT  ?= hello_world

# Mainfile options are based on the main file to be build (default - hello_world)
MAINFILE ?= hello_world

# Linker options are 'on_chip' (default),'flash_load','flash_exec','freertos'
LINKER   ?= on_chip

# Target options are 'sim' (default) and 'pynq-z2'
TARGET   ?= sim
MCU_CFG  ?= mcu_cfg.hjson
PAD_CFG  ?= pad_cfg.hjson

## @section Linux-Emulation

## Generates FEMU
linux-femu-gen: mcu-gen
	$(PYTHON) util/mcu_gen.py --cfg $(MCU_CFG) --pads_cfg $(PAD_CFG) --outdir linux_femu/rtl/ --tpl-sv linux_femu/rtl/linux_femu.sv.tpl
	$(MAKE) verible

## @section Installation

## Generates mcu files core-v-mini-mcu files and build the design with fusesoc
## @param CPU=[cv32e20(default),cv32e40p]
## @param BUS=[onetoM(default),NtoM]
mcu-gen: |venv
	$(PYTHON) util/mcu_gen.py --cfg $(MCU_CFG) --pads_cfg $(PAD_CFG) --outdir hw/core-v-mini-mcu/include --cpu $(CPU) --bus $(BUS) --memorybanks $(MEMORY_BANKS) --external_domains $(EXTERNAL_DOMAINS) --pkg-sv hw/core-v-mini-mcu/include/core_v_mini_mcu_pkg.sv.tpl
	$(PYTHON) util/mcu_gen.py --cfg $(MCU_CFG) --pads_cfg $(PAD_CFG) --outdir hw/core-v-mini-mcu/ --memorybanks $(MEMORY_BANKS) --tpl-sv hw/core-v-mini-mcu/system_bus.sv.tpl
	$(PYTHON) util/mcu_gen.py --cfg $(MCU_CFG) --pads_cfg $(PAD_CFG) --outdir tb/ --memorybanks $(MEMORY_BANKS) --tpl-sv tb/tb_util.svh.tpl
	$(PYTHON) util/mcu_gen.py --cfg $(MCU_CFG) --pads_cfg $(PAD_CFG) --outdir hw/system/ --tpl-sv hw/system/pad_ring.sv.tpl
	$(PYTHON) util/mcu_gen.py --cfg $(MCU_CFG) --pads_cfg $(PAD_CFG) --outdir hw/core-v-mini-mcu/ --tpl-sv hw/core-v-mini-mcu/core_v_mini_mcu.sv.tpl
	$(PYTHON) util/mcu_gen.py --cfg $(MCU_CFG) --pads_cfg $(PAD_CFG) --outdir hw/system/ --tpl-sv hw/system/x_heep_system.sv.tpl
	$(PYTHON) util/mcu_gen.py --cfg $(MCU_CFG) --pads_cfg $(PAD_CFG) --outdir sw/device/lib/runtime --cpu $(CPU) --memorybanks $(MEMORY_BANKS) --header-c sw/device/lib/runtime/core_v_mini_mcu.h.tpl
	$(PYTHON) util/mcu_gen.py --cfg $(MCU_CFG) --pads_cfg $(PAD_CFG) --outdir sw/linker --memorybanks $(MEMORY_BANKS) --linker_script sw/linker/link.ld.tpl
	$(PYTHON) util/mcu_gen.py --cfg $(MCU_CFG) --pads_cfg $(PAD_CFG) --outdir . --memorybanks $(MEMORY_BANKS) --pkg-sv ./core-v-mini-mcu.upf.tpl
	$(PYTHON) util/mcu_gen.py --cfg $(MCU_CFG) --pads_cfg $(PAD_CFG) --outdir hw/ip/power_manager/rtl --memorybanks $(MEMORY_BANKS) --external_domains $(EXTERNAL_DOMAINS) --pkg-sv hw/ip/power_manager/data/power_manager.sv.tpl
	$(PYTHON) util/mcu_gen.py --cfg $(MCU_CFG) --pads_cfg $(PAD_CFG) --outdir hw/ip/power_manager/data --memorybanks $(MEMORY_BANKS) --external_domains $(EXTERNAL_DOMAINS) --pkg-sv hw/ip/power_manager/data/power_manager.hjson.tpl
	bash -c "cd hw/ip/power_manager; source power_manager_gen.sh; cd ../../../"
	$(PYTHON) util/mcu_gen.py --cfg mcu_cfg.hjson --pads_cfg $(PAD_CFG) --outdir sw/device/lib/drivers/power_manager --memorybanks $(MEMORY_BANKS) --external_domains $(EXTERNAL_DOMAINS) --pkg-sv sw/device/lib/drivers/power_manager/data/power_manager.h.tpl
	$(PYTHON) util/mcu_gen.py --cfg mcu_cfg.hjson --pads_cfg $(PAD_CFG) --outdir hw/system/pad_control/data --pkg-sv hw/system/pad_control/data/pad_control.hjson.tpl
	$(PYTHON) util/mcu_gen.py --cfg mcu_cfg.hjson --pads_cfg $(PAD_CFG) --outdir hw/system/pad_control/rtl --pkg-sv hw/system/pad_control/rtl/pad_control.sv.tpl
	bash -c "cd hw/system/pad_control; source pad_control_gen.sh; cd ../../../"
	$(PYTHON) util/mcu_gen.py --cfg mcu_cfg.hjson --pads_cfg $(PAD_CFG) --outdir sw/linker --memorybanks $(MEMORY_BANKS) --linker_script sw/linker/link_flash_exec.ld.tpl
	$(PYTHON) util/mcu_gen.py --cfg mcu_cfg.hjson --pads_cfg $(PAD_CFG) --outdir sw/linker --memorybanks $(MEMORY_BANKS) --linker_script sw/linker/link_flash_load.ld.tpl
	$(PYTHON) ./util/structs_periph_gen.py
	$(MAKE) verible

## Display mcu_gen.py help
mcu-gen-help: |venv
	$(PYTHON) util/mcu_gen.py -h

## Runs verible formating
verible:
	util/format-verible;
	
## @section APP FW Build

## Generates the build folder in sw using CMake to build (compile and linking)
## @param PROJECT=<folder_name_of_the_project_to_be_built>
## @param MAINFILE=<main_file_name_of_the_project_to_be_built WITHOUT EXTENSION>
## @param TARGET=sim(default),pynq-z2
## @param LINKER=on_chip(default),flash_load,flash_exec
app:
	$(MAKE) -C sw PROJECT=$(PROJECT) MAINFILE=$(MAINFILE)  TARGET=$(TARGET) LINKER=$(LINKER)
	
## Just list the different application names available
app-list:
	tree sw/applications/

## @section Simulation

## Verilator simulation			
verilator-sim: |venv
	$(FUSESOC) --cores-root . run --no-export --target=sim --tool=verilator $(FUSESOC_FLAGS) --setup --build openhwgroup.org:systems:core-v-mini-mcu 2>&1 | tee buildsim.log

## Questasim simulation
questasim-sim: |venv
	$(FUSESOC) --cores-root . run --no-export --target=sim --tool=modelsim $(FUSESOC_FLAGS) --setup --build openhwgroup.org:systems:core-v-mini-mcu 2>&1 | tee buildsim.log

## Questasim simulation with HDL optimized compilation
questasim-sim-opt: questasim-sim
	$(MAKE) -C build/openhwgroup.org_systems_core-v-mini-mcu_0/sim-modelsim opt

## Questasim simulation with HDL optimized compilation and UPF power domain description
## @param FUSESOC_FLAGS="--flag=use_upf"
questasim-sim-opt-upf: questasim-sim
	$(MAKE) -C build/openhwgroup.org_systems_core-v-mini-mcu_0/sim-modelsim opt-upf

## Verilator simulation
## @param CPU=cv32e20(default),cv32e40p
## @param BUS=onetoM(default),NtoM
vcs-sim: |venv
	$(FUSESOC) --cores-root . run --no-export --target=sim --tool=vcs $(FUSESOC_FLAGS) --setup --build openhwgroup.org:systems:core-v-mini-mcu 2>&1 | tee buildsim.log
    
## Generates the build output for helloworld applications
## Uses verilator to simulate the HW model and run the FW
## UART Dumping in uart0.log to show recollected results
run-helloworld: mcu-gen verilator-sim |venv
	$(MAKE) -C sw PROJECT=hello_world MAINFILE=hello_world  TARGET=$(TARGET) LINKER=$(LINKER);\
	cd ./build/openhwgroup.org_systems_core-v-mini-mcu_0/sim-verilator; \
	./Vtestharness +firmware=../../../sw/build/hello_world.hex; \
	cat uart0.log; \
	cd ../../..;
	
run-app: mcu-gen verilator-sim |venv
	$(MAKE) -C sw PROJECT=$(PROJECT) MAINFILE=$(MAINFILE)  TARGET=$(TARGET) LINKER=$(LINKER);\
	cd ./build/openhwgroup.org_systems_core-v-mini-mcu_0/sim-verilator; \
	./Vtestharness +firmware=../../../sw/build/$(MAINFILE).hex; \
	cat uart0.log; \
	cd ../../..;

## @section Vivado

## Builds (synthesis and implementation) the bitstream for the FPGA version using Vivado
## @param FPGA_BOARD=nexys-a7-100t,pynq-z2
## @param FUSESOC_FLAGS=--flag=<flagname>
vivado-fpga: |venv
	$(FUSESOC) --cores-root . run --no-export --target=$(FPGA_BOARD) $(FUSESOC_FLAGS) --setup --build openhwgroup.org:systems:core-v-mini-mcu 2>&1 | tee buildvivado.log

vivado-fpga-nobuild: |venv
	$(FUSESOC) --cores-root . run --no-export --target=$(FPGA_BOARD) $(FUSESOC_FLAGS) --setup openhwgroup.org:systems:core-v-mini-mcu 2>&1 | tee buildvivado.log

## @section ASIC
## Note that for this step you need to provide technology-dependent files (e.g., libs, constraints)
asic: |venv
	$(FUSESOC) --cores-root . run --no-export --target=asic_synthesis --setup openhwgroup.org:systems:core-v-mini-mcu 2>&1 | tee builddesigncompiler.log

openroad-sky130: |venv
	git checkout hw/vendor/pulp_platform_common_cells/*
	sed -i 's/(\*[^\n]*\*)//g' hw/vendor/pulp_platform_common_cells/src/*.sv
	$(FUSESOC) --verbose --cores-root . run --target=asic_yosys_synthesis --flag=use_sky130 openhwgroup.org:systems:core-v-mini-mcu 2>&1 | tee buildopenroad.log
	git checkout hw/vendor/pulp_platform_common_cells/*


## @section Program, Execute, and Debug w/ EPFL_Programmer

## Read the id from the EPFL_Programmer flash
flash-readid:
	cd sw/vendor/yosyshq_icestorm/iceprog; \
	./iceprog -d i:0x0403:0x6011 -I B -t;

## Loads the obtained binary to the EPFL_Programmer flash
## @param MAINFILE=<main_file_name_of_the_project_that WAS_built WITHOUT EXTENSION>
flash-prog:
	cd sw/vendor/yosyshq_icestorm/iceprog; \
	./iceprog -d i:0x0403:0x6011 -I B $(mkfile_path)/sw/build/$(MAINFILE).hex;

## Run openOCD w/ EPFL_Programmer
openOCD_epflp:
	xterm -e openocd -f ./tb/core-v-mini-mcu-pynq-z2-esl-programmer.cfg; 

## Start GDB 
gdb_connect:
	$(MAKE) -C sw gdb_connect

## @section Cleaning commands

## Clean the CMake build folder
app-clean:
	$(MAKE) -C sw/build clean

## Removes the CMake build folder
app-restore:
	rm -rf sw/build

## Removes the HW build folder
clean-sim:
	@rm -rf build

## Does the same as app-restore
clean-app: app-restore

## Removes the CMake build folder and the HW build folder
clean-all: app-restore clean-sim
