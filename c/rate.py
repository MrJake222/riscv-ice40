#!/usr/bin/env python3

PORT="/dev/ttyACM2"

import serial, time
import numpy as np

ser = serial.Serial(PORT, 1000000)

BATCH = 20 * 1024

# sync
ser.reset_input_buffer()

while True:
	t1 = time.time()
	ser.read(BATCH)
	t2 = time.time()

	# bytes/s
	rate = BATCH / (t2-t1)

	print(f"{rate/1000:5.1f}kB/s {1e6/rate:6.1f}us/byte")
