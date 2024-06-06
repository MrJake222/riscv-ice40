#define UART0_BASE 	0x10010
#define UART_DATA 	(*(volatile unsigned int*)(UART0_BASE + 0))
#define UART_STATUS	(*(volatile unsigned int*)(UART0_BASE + 4))
#define UART_HAS_RX		(UART_STATUS & (1<<0))
#define UART_TX_EMPTY	(UART_STATUS & (1<<1))

void uart_send(char data) {
	while (!UART_TX_EMPTY);
	UART_DATA = data;
}

int main(void) {
    for (int i=0; i<10; i++) {
        uart_send('a');
    }
    
    while(1);
}

__attribute__ ((section(".boot")))
__attribute__ ((naked))
void _start(void) {
	asm("lui sp, 0x10");
	asm("j main");
}
