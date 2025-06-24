FNAME = darksoc
# input files
VERILOG = $(FNAME).v
VERILOG += darkriscv.v
VERILOG += darkdemux.v
VERILOG += fpu.v
VERILOG += fpu_sumdiff.v
#VERILOG += config.vh
# frequency
FREQ  = 16

SELFDIR := $(dir $(lastword $(MAKEFILE_LIST)))
include ${SELFDIR}/../Makefile
