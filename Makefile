TOPLEVEL_LANG := verilog
SIM := verilator
EXTRA_ARGS += --trace --trace-fst --trace-structs
SIM_CMD_SUFFIX += --trace

VERILOG_SOURCES := i2s_rx.v tdm_tx.v i2s_to_tdm.v

TOPLEVEL = i2s_to_tdm
MODULE = tb_i2s_to_tdm

include $(shell cocotb-config --makefiles)/Makefile.sim

DEVICE := GW1NZ-LV1QN48C6/I5
FAMILY := GW1NZ-1

.PHONY: syn
syn: i2s_to_tdm.json
i2s_to_tdm.json: $(VERILOG_SOURCES)
	yosys -p "read_verilog -sv $(VERILOG_SOURCES); synth_gowin -json i2s_to_tdm.json"

.PHONY: pnr
pnr: i2s_to_tdm.pnr.json
i2s_to_tdm.pnr.json: i2s_to_tdm.json tangnano1k.cst i2s_to_tdm.sdc
	nextpnr-himbaechel --json i2s_to_tdm.json \
	                   --write i2s_to_tdm.pnr.json \
	                   --sdc i2s_to_tdm.sdc \
	                   --device $(DEVICE) \
	                   --vopt family=$(FAMILY) \
	                   --vopt cst=tangnano1k.cst

.PHONY: pack
pack: i2s_to_tdm.fs
i2s_to_tdm.fs: i2s_to_tdm.pnr.json
	gowin_pack -d $(FAMILY) -o i2s_to_tdm.fs i2s_to_tdm.pnr.json

.PHONY: flash
flash: i2s_to_tdm.fs
	openFPGALoader -f -b tangnano1k i2s_to_tdm.fs

.PHONY: flash-sram
flash-sram: i2s_to_tdm.fs
	openFPGALoader -m -b tangnano1k i2s_to_tdm.fs

.PHONY: clean
cleanup:
	rm i2s_to_tdm.fs
	rm i2s_to_tdm.json
	rm i2s_to_tdm.pnr.json
