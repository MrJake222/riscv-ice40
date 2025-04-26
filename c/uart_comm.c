#define UART0_BASE 	0x10010
#define UART_DATA 	(*(volatile unsigned int*)(UART0_BASE + 0))
#define UART_STATUS	(*(volatile unsigned int*)(UART0_BASE + 4))
#define UART_HAS_RX		(UART_STATUS & (1<<0))
#define UART_TX_EMPTY	(UART_STATUS & (1<<1))

#define TIMER_BASE 	0x10018
#define TIME (*(volatile unsigned int*)(TIMER_BASE))

void delay_ms(int x) {
	int t0 = TIME;
	while ((TIME - t0) < (1000*x));
}

void uart_send(char data) {
	while (!UART_TX_EMPTY);
	UART_DATA = data;
}

void uart_send_string(const char* data) {
	while (*data) {
		uart_send(*data++);
	}
}

int main(void) {
	while(1) {
		uart_send_string("Hello, world!\r\n");
		delay_ms(1000);
		
		if (UART_HAS_RX) {
			char rx = UART_DATA;
			uart_send_string("You typed: '");
			uart_send(rx);
			uart_send_string("'\r\n");
		}
	}
		
    while(1) asm("");
}

__attribute__ ((section(".boot")))
__attribute__ ((naked))
void _start(void) {
    asm("lui sp, 0x10");
	asm("j main");
}
