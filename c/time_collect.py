#!/usr/bin/env python3

PORT="/dev/ttyACM2"

import serial, time
import numpy as np

ser = serial.Serial(PORT, 115200)

ser.reset_input_buffer()

measures = []
last = 0
try:
	while True:
		s = time.time()
		b = ser.read_until()
		e = time.time()
		measures.append(e-s)
		
		b = int(b)
		print(f"m={e-s:.3f}  delta={(b-last)/1e6:.3f}")
		last = b

except KeyboardInterrupt:
	print(f"\n\navg={np.average(measures):.5f}  std={np.std(measures):.2e}")

# avg=0.10053  std=2.12e-04
