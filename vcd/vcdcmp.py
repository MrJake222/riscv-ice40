#!/usr/bin/env python3

import os
import sys
import pickle
import hashlib
import lcs, diff
from math import ceil
from vcdvcd import VCDVCD

def get_tv(fname, signame):
	vcd = VCDVCD(fname, signals=[signame], only_sigs=False)
	key = list(vcd.data.keys())[0]
	return vcd.data[key].tv

def bh(s):
	"""bin to hex"""
	if s == "x":
		return "x"
	return hex(int(s, 2))[2:]

def splitconv(tv):
	T, V = [], []
	for t, v in tv:
		T.append(ceil(t/1e6))
		V.append(bh(v))
	return T, V

if len(sys.argv) != 5:
	print(f"Usage: {sys.argv[0]} [vcd1] [sig1] [vcd2] [sig2]")
	exit(1)

file1, sig1, file2, sig2 = sys.argv[1:]

uid = (file1+sig1+file2+sig2).encode()
uhash = hashlib.blake2b(uid, digest_size=6).hexdigest()
ufile = f".{uhash}.tmp"

if os.path.isfile(ufile):
	print(f"Loading cached version of T, V, LCS from {ufile}")
	with open(ufile, "rb") as f:
		T, V, LCS = pickle.load(f)
	t1, t2 = T
	v1, v2 = V

else:
	print("Calulating new values for T, V, LCS")
	
	tv1 = get_tv(file1, sig1)
	tv2 = get_tv(file2, sig2)
	t1, v1 = splitconv(tv1)
	t2, v2 = splitconv(tv2)
	T = [t1, t2]
	V = [v1, v2]

	LCS = lcs.lcs(v1, v2)
	
	with open(ufile, "wb") as f:
		pickle.dump((T, V, LCS), f)
	
	print(f"Saved T, V, LCS as {ufile}")

def get_vts(i_lcs):
	i1 = LCS[i_lcs][0]
	v1 = V[0][i1]
	t1 = T[0][i1]
	i2 = LCS[i_lcs][1]
	v2 = V[1][i2]
	t2 = T[1][i2]
	return v1, t1, v2, t2

def fmt(vts, vtsdiff=None):
	v1, t1, v2, t2 = vts
	
	if vtsdiff is not None:
		_, t1s, _, t2s = vtsdiff
		return f"{t1}us(+{t1-t1s}) {t2}us(+{t2-t2s}) = {v1}"
	
	return f"{t1}us {t2}us = {v1}"

def cb(op, idx, s, e, i_lcs):
	lines = V[idx][s:e]
	times = T[idx][s:e]
	# if lines != ['100000000000111100']:
	if len(lines) > 5:
		pstr = f"{op}{len(lines):4} lines"
		
		vts1 = get_vts(i_lcs)
		pstr += f", last ({fmt(vts1)})"
		
		if i_lcs+1 < len(LCS):
			vts2 = get_vts(i_lcs+1)
			pstr += f", next ({fmt(vts2, vtsdiff=vts1)})"
			
		print(pstr)

print(f"--- {file1}")
print(f"+++ {file2}")
diff.diff(v1, v2, LCS, cb)
