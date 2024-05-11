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

void delay_ms(int x) {
	// tuned manually
	int i = 91 * x;
	while(i--) asm("");
}

int main(void) {
	while(1) {
		printf("%d\n", TIME);
		delay_ms(500);
	}
}

__attribute__ ((section(".boot")))
__attribute__ ((naked))
void _start(void) {
	asm("j main");
}
