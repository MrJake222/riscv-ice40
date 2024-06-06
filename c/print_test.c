#define UART0_BASE 	0x10010
#define UART_DATA 	(*(volatile unsigned int*)(UART0_BASE + 0))
#define UART_STATUS	(*(volatile unsigned int*)(UART0_BASE + 4))
#define UART_HAS_RX		(UART_STATUS & (1<<0))
#define UART_TX_EMPTY	(UART_STATUS & (1<<1))

#include "printf/printf.h"

void _putchar(char data) {
	while (!UART_TX_EMPTY);
	UART_DATA = data;
}

int main(void) {
    for (int i=0; i<=20; i++)
        printf("%d\r\n", i);
    
    // byte access test
    /*
    volatile char c[2];
    c[0] = '2';
    c[1] = '1';
    int i = 2;
    
    while (i) {
        c[--i];
    }
    */
    
    while(1);
}

__attribute__ ((section(".boot")))
__attribute__ ((naked))
void _start(void) {
	asm("lui sp, 0x10");
	asm("j main");
}
