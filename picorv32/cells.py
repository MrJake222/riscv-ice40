#!/usr/bin/env python3

MAXLUT = 5280

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
print(f"total={sum(cnt.values())}")
