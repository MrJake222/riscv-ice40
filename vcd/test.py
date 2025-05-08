import lcs, diff

#     0  1  2  3  4  5  6
v1 = (1, 2, 3, 3, 4, 4, 5)
v2 = (1, 6, 3, 3, 4, 5, 6)
V = [v1, v2]

LCS = lcs.lcs(v1, v2)

print("LCS", LCS)
          
def cb(op, idx, s, e, i_lcs):
	lines = V[idx][s:e]
	i = LCS[i_lcs][idx]
	print(" ", i, V[idx][i])
	print(f"s={s} lines={lines} e={e}")
	if i_lcs+1 < len(LCS):
		j = LCS[i_lcs+1][idx]
		print(" ", j, V[idx][j])
	pstr = f"{op}{len(lines):4} lines"
	# pstr += f", last {fmt(i_lcs)}"
	# if i_lcs+1 < len(LCS):
		# pstr += f", next {fmt(i_lcs+1)}"
		
	print(pstr)
	print()
	# exit()

diff.diff(v1, v2, LCS, cb)
