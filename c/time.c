#define UART0_BASE 	0x10010
#define UART_DATA 	(*(volatile unsigned int*)(UART0_BASE + 0))
#define UART_STATUS	(*(volatile unsigned int*)(UART0_BASE + 4))
#define UART_HAS_RX		(UART_STATUS & (1<<0))
#define UART_TX_EMPTY	(UART_STATUS & (1<<1))

#define TIMER_BASE 	0x10018
#define TIME (*(volatile unsigned int*)(TIMER_BASE))

void uart_send(char data) {
	while (!UART_TX_EMPTY);
	UART_DATA = data;
}

int main(void) {
	int t0 = 0;
	
	while(1) {
		while (TIME - t0 < 100000);
		t0 = TIME;
		
		uart_send('x');
	}
}

__attribute__ ((section(".boot")))
__attribute__ ((naked))
void _start(void) {
	asm("j main");
}
