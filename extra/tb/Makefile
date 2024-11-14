VERILOG += clk.v dbgu32.v pwm.v ram32.v timer.v uartblk.v uart.v
# testbenches
TB += clk_16M.v dbgu32_cts_wait.v dbgu32_wrong_cmd.v dbgu32_back2back.v dbgu32_reset.v
# testbenches dependencies
DEP = dep.v


# simulation
IVSIM_VERILOG = /usr/share/yosys/ice40/cells_sim.v
IVSIM_OPTS    = -D NO_ICE40_DEFAULT_ASSIGNMENTS

# simulate all testbenches
# replaces .v in testbenches with .vcd extension
VCDS = $(patsubst %.v,%.vcd,$(TB)) 
sim: $(VCDS) 
# input files
IVSIM_VERILOG += $(patsubst %,../%,$(VERILOG))

clean:
	# target override is intentional
	rm -f $(VCDS)

# simulate testbench
%.vcd: src/%.v $(DEP) $(IVSIM_VERILOG)
	iverilog -o sim.out -D VCD_OUTPUT="\"$@\"" $(IVSIM_OPTS) $(IVSIM_VERILOG) $<
	vvp sim.out
	rm sim.out
