# for VERILOG design files (prepended with ../ and added to IVSIM_VERILOG)
include ../Makefile
# change default target from all to sim
.DEFAULT_GOAL := sim

# testbenches
TB += dbgu32_mem.v
TB += crv32_dbgu32_mem.v
TB += mem.v
TB += crv32_core.v
TB += crv32_core_stack.v
TB += uartblk.v
# testbenches dependencies
TBDEP += dep.v
TBDEP += dep_core.v
TBDEP += dep_uart.v


# simulation
IVSIM_VERILOG = /usr/share/yosys/ice40/cells_sim.v
IVSIM_OPTS    = -D NO_ICE40_DEFAULT_ASSIGNMENTS
# input files
IVSIM_VERILOG += $(patsubst %,../%,$(VERILOG))

# simulate all testbenches
# replaces .v in testbenches with .vcd extension
VCDS = $(patsubst %.v,%.vcd,$(TB)) 
sim: $(VCDS) 

clean:
	# target override is intentional
	rm -f $(VCDS)

# simulate testbench
%.vcd: %.v $(IVSIM_VERILOG) $(TBDEP)
	iverilog -o sim.out -D VCD_OUTPUT="\"$@\"" $(IVSIM_OPTS) $(IVSIM_VERILOG) $<
	vvp sim.out
	rm sim.out
