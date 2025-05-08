#!/usr/bin/env python3

from vcdvcd import VCDVCD
import sys

if len(sys.argv) != 3:
	print(f"Usage: {sys.argv[0]} [input vcd] [signal name]")
	exit(1)

# Set your paths
vcd_file = sys.argv[1]
target_variable = sys.argv[2]

# Parse the VCD file
vcd = VCDVCD(vcd_file, signals=[target_variable], only_sigs=False)
key = list(vcd.data.keys())[0]
changes = vcd.data[key].tv

for time, value in changes:
	print(value)
