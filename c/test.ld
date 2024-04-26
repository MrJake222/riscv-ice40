MEMORY {
	ram (rwx)	: org = 0x00000, l = 64K
	mmio (rw)	: org = 0x10000, l = 64K
	rom (rx)	: org = 0x20000, l = 64K
}

SECTIONS {
	.text : {
		*(.boot)
		*(.text)
	} > rom
}
