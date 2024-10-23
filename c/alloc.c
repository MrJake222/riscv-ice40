extern unsigned int  _bss_start, _bss_end;
extern unsigned int _data_start, _data_end, _data_src;
extern unsigned int _heap_start, _heap_end;

__attribute__ ((section(".boot")))
__attribute__ ((naked))
void _start(void) {
	// init stack to 0x10000
	// end of ram, grows downwards
    asm("lui sp, 0x10");
	// clear bss
	for (unsigned int* bss=&_bss_start; bss<&_bss_end; *bss++ = 0);
	// load data
	for (unsigned int* data=&_data_start, *idata=&_data_src; data<&_data_end; *data++ = *idata++);
	// jump to main
	asm("j main");
}

#define UART0_BASE 	0x10010
#define UART_DATA 	(*(volatile unsigned int*)(UART0_BASE + 0))
#define UART_STATUS	(*(volatile unsigned int*)(UART0_BASE + 4))
#define UART_HAS_RX		(UART_STATUS & (1<<0))
#define UART_TX_EMPTY	(UART_STATUS & (1<<1))

void _putchar(char data) {
	while (!UART_TX_EMPTY);
	UART_DATA = data;
}

#include "printf/printf.h"
#include "lwmem/lwmem.h"

int main() {
	lwmem_region_t regions[] = { { &_heap_start, (&_heap_end - &_heap_start) }, { NULL, 0 }	};
	printf("heap start %p (size %d)\n", regions[0].start_addr, regions[0].size);
	lwmem_assignmem(regions);
	
	for (int i=0; i<10; i++) {
		char* p = lwmem_malloc(16);
		printf("p = %p\n", p);
	}
	
	while(1) asm("");
} 

// view sections: objdump -t sections.elf
// view contents: objdump -s sections.elf
