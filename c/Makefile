all: led.hex led_breathe.hex uart.hex uart_comm.hex time.hex delay.hex sections.hex ram_test.hex counters.hex print_test.hex alloc.hex fpu.hex

#CFLAGS = -O1
CFLAGS = -O1 -march=rv32i_zicsr -Wall

# override which binaries need printf
# time.elf: time.o printf.o
print_test.elf: print_test.o printf.o
alloc.elf:		alloc.o printf.o lwmem.o
fpu.elf:		fpu.o printf.o

# don't remove elf
.PRECIOUS: %.elf

%.hex: %.elf
	riscv32-unknown-elf-objcopy -O ihex $< $@
	#riscv32-unknown-elf-objdump -S $<

%.elf: %.o
	riscv32-unknown-elf-gcc -T linker.ld -o $@ $^ -nostartfiles -Wl,--print-memory-usage
	@chmod -x $@

%.o: %.c
	riscv32-unknown-elf-gcc -c $(CFLAGS) $< -o $@	\
	-I. -Ilwmem/lwmem/src/include

printf.o: printf/printf.c
	riscv32-unknown-elf-gcc -c $(CFLAGS) $< -o $@	\
		-D PRINTF_DISABLE_SUPPORT_LONG_LONG
		
lwmem.o: lwmem/lwmem/src/lwmem/lwmem.c
	riscv32-unknown-elf-gcc -c $(CFLAGS) $< -o $@	\
	-I. -Ilwmem/lwmem/src/include

clean:
	rm -f *.o *.elf *.hex
