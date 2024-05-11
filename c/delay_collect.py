#!/usr/bin/env python3

PORT="/dev/ttyACM2"

import serial, time
import numpy as np

ser = serial.Serial(PORT, 115200)

# sync
ser.reset_input_buffer()
ser.read(1)

measures = []
try:
	while True:
		s = time.time()
		ser.read(1)
		e = time.time()
		print(e-s)
		measures.append(e-s)

except KeyboardInterrupt:
	print(f"\n\navg={np.average(measures):.5f}  std={np.std(measures):.2e}")

# avg=0.10053  std=2.12e-04
