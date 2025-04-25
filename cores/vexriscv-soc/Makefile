TLD = cvrisc
# input files
VERILOG = $(TLD).v
VERILOG += VexRiscv_smprod_my.v
# VERILOG += VexRiscv_sm_my.v
# VERILOG += VexRiscv_smprod_my_muldiv.v
# extra files
EXTRA += clk.v ram32.v dbgu32.v uart.v
EXTRA += pwm.v uartblk.v timer.v
# pin definitions / freq
PCF   = $(TLD).pcf
FREQ  = 16


SELFDIR := $(dir $(lastword $(MAKEFILE_LIST)))
include ${SELFDIR}/../Makefile
