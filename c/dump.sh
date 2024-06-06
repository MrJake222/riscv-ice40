#!/bin/bash

# dump in verilog rom program code
# $1 -- elf file

riscv32-unknown-elf-objdump -S $1 | grep "^   2" | tr ':' ';' | awk '{print "force soc.dbg_adr = 32Xh"$1" force soc.dbg_do = 32Xh"$2"; #1000; // "$3"\t"$4}' | tr X "'"
