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
    int fail = 0;
    
    for (int adr=0x00000; adr<0x10000; adr+=4) {
        volatile unsigned int* acc = (volatile unsigned int*)adr;
        *acc = 0xA5A50000 | adr;
    }
    
    for (int adr=0x00000; adr<0x10000; adr+=4) {
        volatile unsigned int* acc = (volatile unsigned int*)adr;
        if (*acc != (0xA5A50000 | adr)) {
            fail = 1;
        }
    }
    
    // 'a' no fail
    // 'b' fail
    uart_send(fail + 'a');
    
	while(1) asm("");
}

__attribute__ ((section(".boot")))
__attribute__ ((naked))
void _start(void) {
    asm("lui sp, 0x10");
	asm("j main");
}
