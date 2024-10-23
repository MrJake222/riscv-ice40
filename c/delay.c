#define UART0_BASE 	0x10010
#define UART_DATA 	(*(volatile unsigned int*)(UART0_BASE + 0))
#define UART_STATUS	(*(volatile unsigned int*)(UART0_BASE + 4))
#define UART_HAS_RX		(UART_STATUS & (1<<0))
#define UART_TX_EMPTY	(UART_STATUS & (1<<1))

void delay_ms(int x) {
	// tuned manually
	// picorv32:  91 @ 24 MHz
	// vexriscv: 167 @ 16 MHz
	int i = 167 * x * 16;
	while(i--) asm("");
}

void uart_send(char data) {
	while (!UART_TX_EMPTY);
	UART_DATA = data;
}

int main(void) {
	
	// send chars repeatedly
	//for (int i=0; i<100; i++) {
	while(1) {
		uart_send('x');
		delay_ms(100);
	}
}

__attribute__ ((section(".boot")))
__attribute__ ((naked))
void _start(void) {
    asm("lui sp, 0x10");
	asm("j main");
}
