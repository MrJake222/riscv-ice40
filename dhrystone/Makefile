all: dhrystone.hex

CFLAGS = -O3 -D printf=printf_ -ffreestanding -nostdlib
# CFLAGS = -O3 -D printf=printf_ -ffreestanding -nostdlib -mabi=ilp32 -march=rv32im

%.hex: %.elf
	riscv32-unknown-elf-objcopy -O ihex $< $@
	#riscv32-unknown-elf-objdump -S $<

dhrystone.elf: main.o dhry.o stdlib.o printf.o
	riscv32-unknown-elf-ld -T linker.ld -o $@ $^	\
		-L/opt/riscv32i/lib/gcc/riscv32-unknown-elf/14.2.0 -lgcc

printf.o: printf/printf.c
	riscv32-unknown-elf-gcc -c $(CFLAGS) $< -o $@	\
		-D PRINTF_DISABLE_SUPPORT_FLOAT				\

dhry.o: dhry.c
	riscv32-unknown-elf-gcc -c $(CFLAGS) $< -o $@	\
		-Wno-implicit-function-declaration -Wno-implicit-int

%.o: %.c
	riscv32-unknown-elf-gcc -c $(CFLAGS) $< -o $@

clean:
	rm -f *.o *.elf *.hex
