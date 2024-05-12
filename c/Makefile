all: led.hex uart.hex time.hex delay.hex ram.hex

CFLAGS = -O1

# override which binaries need printf
time.elf: time.o printf.o

# don't remove elf
.PRECIOUS: %.elf

%.hex: %.elf
	riscv32-unknown-elf-objcopy -O ihex $< $@
	#riscv32-unknown-elf-objdump -S $<

%.elf: %.o
	riscv32-unknown-elf-ld -T linker.ld -o $@ $^	\
		-L/opt/riscv32i/lib/gcc/riscv32-unknown-elf/13.2.0 -lgcc

%.o: %.c
	riscv32-unknown-elf-gcc -c $(CFLAGS) $< -o $@

printf.o: printf/printf.c
	riscv32-unknown-elf-gcc -c $(CFLAGS) $< -o $@	\
		-D PRINTF_DISABLE_SUPPORT_FLOAT				\
		-D PRINTF_DISABLE_SUPPORT_LONG_LONG

clean:
	rm -f *.o *.elf *.hex
