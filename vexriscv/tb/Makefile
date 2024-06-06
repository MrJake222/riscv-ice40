# for VERILOG design files (prepended with ../ and added to IVSIM_VERILOG)
include ../Makefile
# change default target from all to sim
.DEFAULT_GOAL := sim

# testbenches
TB += cvrisc_bus_data_read.v
TB += cvrisc_bus_data_write.v
TB += cvrisc_bus_instr.v
TB += cvrisc_uart0.v
TB += cvrisc_stack.v
TB += cvrisc_bus_data_byte_access.v
TB += cvrisc_counters.v
TB += dbgu32_mem.v
# testbenches dependencies
DEP += clk.v
DEP += core.v
DEP += uart.v

# paths
#TB  := $(patsubst %,src/%,$(TB))
DEP := $(patsubst %,dep/%,$(DEP))


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
%.vcd: src/%.v $(DEP) $(IVSIM_VERILOG)
	iverilog -o sim.out -D VCD_OUTPUT="\"$@\"" $(IVSIM_OPTS) $(IVSIM_VERILOG) $<
	vvp sim.out
	rm sim.out
