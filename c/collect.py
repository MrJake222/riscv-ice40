#!/usr/bin/env python3

PORT="/dev/ttyACM2"

import serial, time
import numpy as np

ser = serial.Serial(PORT, 1000000)

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
	avg = np.average(measures)
	std = np.std(measures)
	print(f"\n\navg={avg:.5f}  std={std/avg*100:.6f}%")

# delay: 		avg=0.10055  std=2.57e-05
# time:  		avg=0.10038  std=3.61e-05   0.035%
# time 16MHz: 	avg=0.10034  std=			0.051%
# time 16MHz: 	avg=0.10006  std= 			0.032% (flush in main)
