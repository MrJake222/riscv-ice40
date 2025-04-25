TLD = crv32
# input files
VERILOG = $(TLD).v
VERILOG += picorv32.v
# extra files
EXTRA += clk.v ram32.v dbgu32.v uart.v
EXTRA += pwm.v uartblk.v timer.v
# pin definitions / freq
PCF   = $(TLD).pcf
FREQ  = 16

SELFDIR := $(dir $(lastword $(MAKEFILE_LIST)))
include ${SELFDIR}/../Makefile
