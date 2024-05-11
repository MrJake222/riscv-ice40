all: led.hex uart.hex

%.hex: %.c
	riscv32-unknown-elf-gcc -c -O1 $< -o $<.o

	riscv32-unknown-elf-ld	\
		-T linker.ld	\
		$<.o			\
		-o $<.elf	\
		/opt/riscv32i/lib/gcc/riscv32-unknown-elf/13.2.0/libgcc.a

	riscv32-unknown-elf-objcopy -O ihex $<.elf $@
	riscv32-unknown-elf-objdump -S $<.elf

clean:
	rm -f *.o *.elf *.hex
