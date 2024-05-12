// TODO init sections to 0
extern int heap_memory_used;

__attribute__ ((section(".boot")))
__attribute__ ((naked))
void _start(void) {
	heap_memory_used = 0;
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

int main() {
	const int runs = 760;
	
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
	printf("cpi:  %llu.%03llu\n", cpmi/1000, cpmi%1000);
	
	const uint32_t dhpms = ((uint64_t) runs) * 1e9 / time_us;
	printf("dhrystones per second: %u.%03u\n", dhpms/1000, dhpms%1000);
	
	const uint32_t dmmips = dhpms / 1757;
	printf("dmips: %d.%03d\n", dmmips/1000, dmmips%1000);
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
