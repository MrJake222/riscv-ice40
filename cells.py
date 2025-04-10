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
cnt3 = defaultdict(lambda: 0)
cnt4 = defaultdict(lambda: 0)

for x in mods:
    if "LUT" in x:
        # split and strip direct LUT name
        idx = x.index("_SB_")
        signame = x[:idx]
        cnt[signame] += 1
        
        modnames = signame.split(".")
        cnt2[modnames[0]] += 1
        modname3 = ".".join(modnames[:2])
        cnt3[modname3] += 1
        modname4 = ".".join(modnames[:3])
        cnt4[modname4] += 1
        # todo refactor

def print_sorted(D):
    keys = list(D.keys())
    keys.sort(key=lambda x: D[x])
    keylen = max(map(len, keys))
    for k in keys:
        p = round(D[k] / MAXLUT * 100)
        p = f"({p}%)"
        print(f"\t {k:{keylen}}   {D[k]:5}  {p:>6}")

# print()
# print("signal LUT usage")
# print_sorted(cnt)

# print()
print(" second-level modules LUT usage")
print_sorted(cnt2)

# print()
# print(" third-level modules LUT usage")
# print_sorted(cnt3)

# print()
# print(" fourth-level modules LUT usage")
# print_sorted(cnt4)

# print()
print()
total = sum(cnt.values())
p = round(total / MAXLUT * 100)
p = f"({p}%)"
print(f" total {total:5} {p:>6}")
