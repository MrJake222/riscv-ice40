TLD = crv32
# input files
VERILOG = $(TLD).v
VERILOG += clk.v ram32.v dbgu32.v uart.v pwm.v
VERILOG += picorv32-impl/picorv32.v
VERILOG += uartblk.v
# testbenches
TB += tb_dbgu32_mem.v
TB += tb_crv32_dbgu32_mem.v
TB += tb_mem.v
TB += tb_crv32_core.v
TB += tb_crv32_core_stack.v
TB += tb_uartblk.v
# testbenches dependencies
TBDEP += tb_dep.v
TBDEP += tb_dep_core.v
TBDEP += tb_dep_uart.v
# pin definitions
PCF   = $(TLD).pcf


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
PNR_OPTS	= --up5k --package sg48
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


# verify icarus verilog options
IV_VERILOG = /usr/share/yosys/ice40/cells_sim.v
IV_OPTS    = -D VCD_OUTPUT= -D NO_ICE40_DEFAULT_ASSIGNMENTS


# simulation
IVSIM_VERILOG = /usr/share/yosys/ice40/cells_sim.v
IVSIM_OPTS    = -D NO_ICE40_DEFAULT_ASSIGNMENTS


# first -> default
all: verify bin util

bin: $(BIN)
uf2: $(UF2)

# simulate all testbenches
# replaces .v in testbenches with .vcd extension
VCDS = $(patsubst %.v,%.vcd,$(TB)) 
sim: $(VCDS)


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

# simulate testbench
%.vcd: %.v $(VERILOG) $(TBDEP)
	iverilog -o sim.out -D VCD_OUTPUT="\"$@\"" $(IVSIM_OPTS) $(IVSIM_VERILOG) $(VERILOG) $<
	vvp sim.out
	rm sim.out

verify: $(VERILOG)
	iverilog -o /dev/null $(IV_OPTS) $(IV_VERILOG) $(VERILOG)
	
util:
	@echo -e "\n utilization:"
	@./util.py $(UTIL)
	@echo
	
cells:
	@echo -e "\n cell usage:"
	@./cells.py $(JSON) $(TLD)
	@echo
	
clean:
	rm -f $(JSON) $(ASC) $(BIN) $(UF2) $(UTIL) $(VCDS)
	
prgflash: $(BIN)
	$(PRG_EXEC) $(PRG_OPTS) $(PRG_FLASH) -D $<
	
prgcram: $(BIN)
	$(PRG_EXEC) $(PRG_OPTS) $(PRG_CRAM) -D $<
