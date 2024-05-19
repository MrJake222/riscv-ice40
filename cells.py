#!/usr/bin/env python3

MAXLUT = 5280

import sys, json
from collections import defaultdict

if len(sys.argv) == 3:
	filename = sys.argv[1]
	tld = sys.argv[2]
	
elif len(sys.argv) == 2:
	filename = sys.argv[1]
	tld = filename.split(".")[0]
	
else:
	print(f"Usage: {sys.argv[0]} <tld.hw.json> [tld name]")
	exit(1)

J = json.load(open(filename))
#print(J["modules"].keys())
mods = J["modules"][tld]["cells"]

cnt = defaultdict(lambda: 0)
cnt2 = defaultdict(lambda: 0)

for x in mods:
    if "LUT" in x:
        # split and strip direct LUT name
        idx = x.index("_SB_")
        signame = x[:idx]
        cnt[signame] += 1
        
        modname = signame.split(".")[0]
        cnt2[modname] += 1

def print_sorted(D):
    keys = list(D.keys())
    keys.sort(key=lambda x: D[x])
    keylen = max(map(len, keys))
    for k in keys:
        p = f"({D[k] / MAXLUT * 100:.0f}%)"
        print(f"\t {k:{keylen}}   {D[k]:4}  {p:>5}")

print()
print("signal LUT usage")
print_sorted(cnt)

print()
print("second-level modules LUT usage")
print_sorted(cnt2)

print()
print()
total = sum(cnt.values())
print(f"total {total} ({total / MAXLUT * 100:.0f}%)")
