MEMORY {
	ram (rwx)	: org = 0x00000, l = 64K
	mmio (rw)	: org = 0x10000, l = 64K
	rom (rx)	: org = 0x20000, l = 64K
}

/* star before () means include every file */
/*      inside () it means load every section */

/* "ram AT> rom" will store the section at ROM but addresses
   will be in RAM */

SECTIONS {
	.text : {
		*(.boot)
		*(.text .text.* .gnu.linkonce.t.*)
		*(.rodata .rodata* .gnu.linkonce.r.*)
	} > rom
	
	.data : {
		_data_start = ABSOLUTE(.);
		*(.data .data.*)
		*(.sdata .sdata.*)
		_data_end = ABSOLUTE(.);
	} > ram AT> rom
	
	_data_src = LOADADDR(.data);
	
	.bss : {
		_bss_start = ABSOLUTE(.);
		*(.bss .bss.*)
		*(.sbss .sbss.*)
		_bss_end = ABSOLUTE(.);
	} > ram
}
