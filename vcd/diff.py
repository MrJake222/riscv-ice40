def diff(c1, c2, LCS, cb):
	C = [c1, c2]
	i1 = 0
	i2 = 0
	i_lcs = 0
	while i1 < len(c1) or i2 < len(c2):
		in_first = False
		in_second = False
		if i_lcs < len(LCS):
			lcs = LCS[i_lcs]
			in_first =  (i1 == lcs.i)
			in_second = (i2 == lcs.j)

		# print("DIFF", i1, i2, i_lcs, in_first, in_second)

		if in_first and in_second:
			i1 += 1
			i2 += 1
			i_lcs += 1

		else:
			def lines(i_start, idx):
				i = i_start
				while i < len(C[idx]) and (i_lcs >= len(LCS) or i != LCS[i_lcs][idx]):
					i += 1
				return i_start, i

			if not in_first and i1 < len(c1):
				i1s, i1 = lines(i1, 0)
				cb("-", 0, i1s, i1, i_lcs-1)

			if not in_second:
				i2s, i2 = lines(i2, 1)
				cb("+", 1, i2s, i2, i_lcs-1)
