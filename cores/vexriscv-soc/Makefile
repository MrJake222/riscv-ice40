FNAME = vexsoc
# input files
VERILOG = $(FNAME).v
#VERILOG += VexRiscv_smprod_my.v
VERILOG += VexRiscv_smprod_my_nopers.v
# VERILOG += VexRiscv_sm_my.v
# VERILOG += VexRiscv_smprod_my_muldiv.v
# frequency
FREQ  = 8


SELFDIR := $(dir $(lastword $(MAKEFILE_LIST)))
include ${SELFDIR}/../Makefile
