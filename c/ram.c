#define UART0_BASE 	0x10010
#define UART_DATA 	(*(volatile unsigned int*)(UART0_BASE + 0))
#define UART_STATUS	(*(volatile unsigned int*)(UART0_BASE + 4))
#define UART_HAS_RX		(UART_STATUS & (1<<0))
#define UART_TX_EMPTY	(UART_STATUS & (1<<1))

void uart_send(char data) {
	while (!UART_TX_EMPTY);
	UART_DATA = data;
}

//char temp[256];
char arr[256];

int main(void) {
	/*for (int i=0; i<256; i++)
		temp[i] = 2*i;
	uart_send(temp[5]);
	uart_send(temp[6]);*/

	for (int i=0; i<64; i++) {
		//uart_send(i);
		arr[i] = 4*i;
		uart_send(i);
	}
	uart_send(arr[5]);
	uart_send(arr[6]);
	
	while(1) asm("");
}

__attribute__ ((section(".boot")))
__attribute__ ((naked))
void _start(void) {
	asm("j main");
}
