################################################################################
#                   _________ _
# |\     /||\     /|\__   __/( (    /|
# | )   ( || )   ( |   ) (   |  \  ( |
# | |   | || | _ | |   | |   |   \ | |
# | |   | || |( )| |   | |   | (\ \) |
# | |   | || || || |   | |   | | \   |
# | (___) || () () |___) (___| )  \  |
# \_______/(_______)\_______/|/    )_)
#
# Copyright: 2024 Fraunhofer EAS/IIS
# Author: Hannes Ellinger
#         hannes.ellinger@eas.iis.fraunhofer.de
#         Jakob Wicht
#         jakob.wicht@eas.iis.fraunhofer.de
#
################################################################################
TOPLEVEL_LANG := vhdl
SIM := ghdl
SIM_ARGS += --vcd=wave.vcd
COMPILE_ARGS += --std=08

VHDL_SOURCES := i2s_rx.vhd tdm_tx.vhd i2s_to_tdm.vhd

TOPLEVEL = i2s_to_tdm
MODULE   = tb_i2s_to_tdm

include $(shell cocotb-config --makefiles)/Makefile.sim

# syn_gowin:
# 	ghdl -a --std=08 i2s_rx.vhd tdm_tx.vhd i2s_to_tdm.vhd
# 	yosys -m /usr/lib/ghdl_yosys.so -p "ghdl --std=08 i2s_to_tdm; synth_gowin -json i2s_to_tdm.json"
# 	nextpnr-gowin --json i2s_to_tdm.json --write i2s_to_tdm.pnr.json --freq 12.288 --device GW1NZ-LV1QN48C6/I5 --family GW1NZ-1 --cst tangnano1k.cst

syn:
	ghdl -a --std=08 i2s_rx.vhd tdm_tx.vhd i2s_to_tdm.vhd
	yosys -m /usr/lib/ghdl_yosys.so -p "ghdl --std=08 i2s_to_tdm; synth_ice40 -json i2s_to_tdm.json"
	nextpnr-ice40 --json i2s_to_tdm.json --asc i2s_to_tdm.asc --pcf i2s_to_tdm.pcf --freq 12.288 --hx8k --package ct256

# flash_gowin:
# 	gowin_pack -d GW1NZ-1 -o pack.fs i2s_to_tdm.pnr.json
# 	openFPGALoader -b tangnano1k pack.fs

flash:
	icepack i2s_to_tdm.asc i2s_to_tdm.bin
	iceprogduino/iceprogduino -I /dev/ttyACM2 i2s_to_tdm.bin
