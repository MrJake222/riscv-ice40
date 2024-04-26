#!/usr/bin/env python3

import sys, json
from collections import defaultdict

J = json.load(open(sys.argv[1]))
mods = J["modules"][sys.argv[2]]["cells"]

cnt = defaultdict(lambda: 0)
cnt2 = defaultdict(lambda: 0)

for x in mods:
    if "LUT" in x:
        # split and strip direct LUT name
        idx = x.index("_SB_")
        modname = x[:idx]
        cnt[modname] += 1
        
        modname = x.split(".")[:-1]
        modname = ".".join(modname)
        cnt2[modname] += 1

def print_sorted(D):
    keys = list(D.keys())
    keys.sort(key=lambda x: D[x])
    for k in keys:
        print(f"{k:25} {D[k]:6}")

print()
print("1")
print_sorted(cnt)

print()
print("2")
print_sorted(cnt2)

print()    
print("total")    
print(sum(cnt.values()))
