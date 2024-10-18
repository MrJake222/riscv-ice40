all: led.hex led_breathe.hex uart.hex uart_comm.hex time.hex delay.hex sections.hex ram_test.hex counters.hex print_test.hex

#CFLAGS = -O1
CFLAGS = -O1 -march=rv32i_zicsr

# override which binaries need printf
# time.elf: time.o printf.o
print_test.elf: print_test.o printf.o

# don't remove elf
.PRECIOUS: %.elf

%.hex: %.elf
	riscv32-unknown-elf-objcopy -O ihex $< $@
	#riscv32-unknown-elf-objdump -S $<

%.elf: %.o
	riscv32-unknown-elf-ld -T linker.ld -o $@ $^	\
		-L/opt/riscv32i/lib/gcc/riscv32-unknown-elf/14.2.0 -lgcc
	@chmod -x $@

%.o: %.c
	riscv32-unknown-elf-gcc -c $(CFLAGS) $< -o $@

printf.o: printf/printf.c
	riscv32-unknown-elf-gcc -c $(CFLAGS) $< -o $@	\
		-D PRINTF_DISABLE_SUPPORT_FLOAT				\
		-D PRINTF_DISABLE_SUPPORT_LONG_LONG

clean:
	rm -f *.o *.elf *.hex
