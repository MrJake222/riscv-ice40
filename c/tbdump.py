#!/usr/bin/env python3

import sys
from elftools.elf.elffile import ELFFile

def read_elf_and_dump_32bit(filename, section_name=".rodata"):
    with open(filename, 'rb') as f:
        elf = ELFFile(f)

        section = elf.get_section_by_name(section_name)
        if not section:
            print(f"Section '{section_name}' not found.")
            return

        data = section.data()
        addr = section['sh_addr']

        for i in range(0, len(data) - 3, 4):
            word = int.from_bytes(data[i:i+4], byteorder='little')
            print(f"force soc.dbg_adr = 32'h{addr + i:05x}; force soc.dbg_do = 32'h{word:08x}; #1000;")

if len(sys.argv) != 2:
	print(f"Usage: {sys.argv[0]} [elf file]")
	exit(1)

read_elf_and_dump_32bit(sys.argv[1], section_name=".text")  # or .data, .text, etc.
