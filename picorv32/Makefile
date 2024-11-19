TLD = crv32
# input files
VERILOG = $(TLD).v
VERILOG += picorv32.v
# extra files
EXTRA += clk.v ram32.v dbgu32.v uart.v
EXTRA += pwm.v uartblk.v timer.v
VERILOG += $(patsubst %,../extra/%,$(EXTRA))
# pin definitions
PCF   = $(TLD).pcf
FREQ  = 24


# intermediate files
JSON = $(TLD).hw.json
ASC  = $(TLD).asc
UTIL = $(TLD)_util.hw.json
# result file
BIN  = $(TLD).bin
UF2  = $(TLD).uf2


# config
# -q is quiet
SYNTH_EXEC	= yosys
SYNTH_SCR	= synth_ice40
SYNTH_OPTS	= -q
# ---
# -q is quiet
PNR_EXEC	= nextpnr-ice40
PNR_OPTS	= --up5k --package sg48 --freq $(FREQ)
# ---
PACK_EXEC	= icepack
PACK_OPTS	= 
# ---
BIN2UF2		= bin2uf2
# ---
PRG_EXEC	= dfu-util
PRG_OPTS	= -d 1209:b1c0
PRG_CRAM	= -a "iCE40 DFU (CRAM)"
PRG_FLASH	= -a "iCE40 DFU (Flash)"
# ---
PY_UTIL     = ../util.py
PY_CELLS    = ../cells.py

# verify icarus verilog options
IV_VERILOG = /usr/share/yosys/ice40/cells_sim.v
IV_OPTS    = -D VCD_OUTPUT= -D NO_ICE40_DEFAULT_ASSIGNMENTS


# first -> default
all: verify bin uf2 util

bin: $(BIN)
uf2: $(UF2)

# synthesize
$(JSON): $(VERILOG)
	$(SYNTH_EXEC) -p "$(SYNTH_SCR) -top $(TLD) -json $(JSON)" $(SYNTH_OPTS) $(VERILOG)
	
# Place and route
$(ASC): $(JSON) $(PCF)
	$(PNR_EXEC) $(PNR_OPTS) --pcf $(PCF) --json $(JSON) --asc $(ASC) --report $(UTIL)
	
# pack to bin
$(BIN): $(ASC)
	$(PACK_EXEC) $(PACK_OPTS) $(ASC) $@

# bin to uf2
$(UF2): $(BIN)
	$(BIN2UF2) -o $@ $<

verify: $(VERILOG)
	iverilog -o /dev/null $(IV_OPTS) $(IV_VERILOG) $(VERILOG)
	
util: $(ASC)
	@echo -e "\n utilization:"
	@$(PY_UTIL) $(UTIL)
	@echo
	
cells: $(JSON)
	@echo -e "\n cell usage:"
	@$(PY_CELLS) $(JSON) $(TLD)
	@echo
	
clean:
	rm -f $(JSON) $(ASC) $(BIN) $(UF2) $(UTIL)
	
prgflash: $(BIN)
	$(PRG_EXEC) $(PRG_OPTS) $(PRG_FLASH) -D $<
	
prgcram: $(BIN)
	$(PRG_EXEC) $(PRG_OPTS) $(PRG_CRAM) -D $<
