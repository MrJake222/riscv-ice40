#!/usr/bin/env python3

import sys, json

J = json.load(open(sys.argv[1]))
util = J["utilization"]

keys = list(util.keys())
keys.sort(key=lambda x: util[x]['available'], reverse=True)

for name in keys:
	piece = util[name]
	used  = piece['used']
	avail = piece['available']
	print(f"{name:>20}: {used:6} / {avail:<6}  {used/avail*100:>3.0f} %")
