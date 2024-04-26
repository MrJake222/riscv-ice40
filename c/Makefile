all:
	riscv32-unknown-elf-gcc -c -O1 test.c

	riscv32-unknown-elf-ld	\
		-T test.ld	\
		test.o		\
		-o test.elf	\
		/opt/riscv32i/lib/gcc/riscv32-unknown-elf/13.2.0/libgcc.a

	riscv32-unknown-elf-objcopy -O ihex test.elf test.hex
	riscv32-unknown-elf-objdump -S test.elf

clean:
	rm -f test.o test.elf test.hex
