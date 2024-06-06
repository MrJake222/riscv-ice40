extern unsigned int _bss_start, _bss_end;

__attribute__ ((section(".boot")))
__attribute__ ((naked))
void _start(void) {
    asm("lui sp, 0x10");
	// clear bss
	for (unsigned int* bss=&_bss_start; bss<&_bss_end; *bss++ = 0);
	asm("j main");
}

#define UART0_BASE 	0x10010
#define UART_DATA 	(*(volatile unsigned int*)(UART0_BASE + 0))
#define UART_STATUS	(*(volatile unsigned int*)(UART0_BASE + 4))
#define UART_HAS_RX		(UART_STATUS & (1<<0))
#define UART_TX_EMPTY	(UART_STATUS & (1<<1))

#define TIMER_BASE 	0x10018
#define TIME (*(volatile unsigned int*)(TIMER_BASE))

#include "printf/printf.h"
void _putchar(char data) {
	if (data == '\n')
		_putchar('\r');
	
	while (!UART_TX_EMPTY);
	UART_DATA = data;
}

#include "dhry.h"

long start_cycle;
long start_instr;
long start_time;

long end_cycle;
long end_instr;
long end_time;

#include <stdint.h>

int round(int nom, int denom) {
	int res_x10 = nom / (denom / 10);
	int res = res_x10 / 10;
	
	if (res_x10 % 10 >= 5)
		return res + 1;
	
	return res;
}

int main() {
	for (unsigned int* bss=&_bss_start; bss<&_bss_end; bss+=0x100)
		printf("bss %p: %d\n", bss, *bss);
	
	const int runs = 14500 * 5;
	
	dhrystone(runs);
	
	const int cycles  = end_cycle - start_cycle;
	const int instrs  = end_instr - start_instr;
	const int time_us = end_time  - start_time;
	
	printf("runs:   %d\n", runs);
	printf("cycles: %d\n", cycles);
	printf("instr:  %d\n", instrs);
	printf("time:   %d us (%d.%06d s)\n", time_us, time_us / 1000000, time_us % 1000000);
	printf("\n");
	
	// "m" in variable name means mili (10^-3)
	
	const uint64_t cpmi = ((uint64_t) cycles) * 1000 / instrs;
	printf("cpi: %llu.%03llu\n", cpmi/1000, cpmi%1000);
	
	const uint32_t dhpms = ((uint64_t) runs) * 1e9 / time_us;
	printf("dhrystones per second: %u\n", dhpms/1000);
	
	const uint32_t dmmips = dhpms / 1757;
	printf("dmips: %d.%03d\n", dmmips/1000, dmmips%1000);
	
	const int f_clk_mhz = round(cycles, time_us);
	const int dmmips_per_mhz = dmmips / f_clk_mhz;
	printf("dmips / MHz: %d.%03d  (%d MHz)\n", dmmips_per_mhz/1000, dmmips_per_mhz%1000, f_clk_mhz);
}

long cycle() {
	int cycles;
	asm volatile ("rdcycle %0" : "=r"(cycles));
	return cycles;
}

long instr() {
	int insns;
	asm volatile ("rdinstret %0" : "=r"(insns));
	return insns;
}

void dhrystone_timer_start() {
	start_cycle = cycle();
	start_instr = instr();
	start_time = TIME;
}

void dhrystone_timer_end() {
	end_cycle = cycle();
	end_instr = instr();
	end_time = TIME;
}
