from numba import njit
from dataclasses import dataclass

@dataclass
class LCSItem:
	# value: any
	i: int # position index from the first iterable
	j: int #           --||--       second iterable
	
	def __getitem__(self, item):
		if item == 0:
			return self.i
		elif item == 1:
			return self.j
		else:
			raise IndexError("no such index")
	
	def __repr__(self):
		return f"{{i={self.i},j={self.j}}}"

@njit
def lcs_numba(X, Y):
	x = len(X)
	y = len(Y)
	T = [[0]*(y+1) for _ in range(x+1)]

	for i in range(x+1): T[i][0] = 0
	for j in range(y+1): T[0][j] = 0

	for i in range(1, x+1):
		for j in range(1, y+1):
			if X[i-1] == Y[j-1]:
				T[i][j] = T[i-1][j-1] + 1
			else:
				T[i][j] = max(T[i-1][j], T[i][j-1])

	i = x
	j = y
	LCSi = []
	LCSj = []
	while i > 0 or j > 0:
		if i>0 and j>0 and X[i-1] == Y[j-1]:
			LCSi.append(i-1)
			LCSj.append(j-1)
			i -= 1
			j -= 1

		elif i>0 and T[i-1][j] == T[i][j]:
			i -= 1

		elif j>0 and T[i][j-1] == T[i][j]:
			j -= 1

	LCSi.reverse()
	LCSj.reverse()
	return LCSi, LCSj


def lcs(X, Y):
	LCS = []
	LCSi, LCSj = lcs_numba(X, Y)
	for i, j in zip(LCSi, LCSj):
		LCS.append(LCSItem(i, j))
	return LCS
