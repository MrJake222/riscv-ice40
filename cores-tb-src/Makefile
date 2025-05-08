# include this file in *-soc/tb tests


# testbenches
TB += t1_bus_instr.v
TB += t2_bus_data_read.v
TB += t3_bus_pgm_read.v
TB += t4_bus_data_write.v
TB += t5_bus_data_write_readback.v
TB += t6_bus_data_write_burstrw.v
TB += t7_bus_data_per_byte.v
TB += t8_counters.v
TB += t9_stack.v
TB += t10_uart0_tx.v
TB += t11_uart0_rx.v
TB += t12_dbgu32_mem.v
TB += t20_custom.v
# testbenches dependencies
DEP = dep.v
# time multiplier
TMUL ?= 1

# simulation
IVSIM_VERILOG = /usr/share/yosys/ice40/cells_sim.v
IVSIM_OPTS    = -D NO_ICE40_DEFAULT_ASSIGNMENTS
# input files
IVSIM_VERILOG += $(patsubst %,../%,$(VERILOG))

# change default target from all to sim
.DEFAULT_GOAL := sim

# simulate all testbenches
# replaces .v in testbenches with .vcd extension
VCDS = $(patsubst %.v,%.vcd,$(TB)) 
sim: $(VCDS) 

clean:
	# target override is intentional
	rm -f $(VCDS)

# simulate testbench
%.vcd: src/%.v $(DEP) $(IVSIM_VERILOG)
	iverilog -o sim.out -D VCD_OUTPUT="\"$@\"" -D TMUL=$(TMUL) $(IVSIM_OPTS) $(IVSIM_VERILOG) $<
	vvp sim.out
	rm sim.out
