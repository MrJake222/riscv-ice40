extern unsigned int _bss_start, _bss_end;
extern unsigned int _data_start, _data_end, _data_src;

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
	asm("j main");
}

#define UART0_BASE 	0x10010
#define UART_DATA 	(*(volatile unsigned int*)(UART0_BASE + 0))
#define UART_STATUS	(*(volatile unsigned int*)(UART0_BASE + 4))
#define UART_HAS_RX		(UART_STATUS & (1<<0))
#define UART_TX_EMPTY	(UART_STATUS & (1<<1))

void uart_send(char data) {
	while (!UART_TX_EMPTY);
	UART_DATA = data;
}

// bss/sbss
char this_is_bss[256];
int this_is_bss2;
int this_is_bss3 = 0;

// this points into text, however the pointer is
// variable but initialized -> s/data section
const char* this_is_data = "Hello World";
char this_is_data2 = 5;
int this_is_data3[4] = {0xde, 0xad, 0xbe, 0xef};
// read-only pointer goes into s/rodata
const char* const this_is_rodata = "Hello world";
const int this_is_rodata2 = 7;

// string pointer content goes into .rodata.str1.4

#pragma GCC optimize ("O0")
int main() {
	int fail = 0;
	
	// bss zero test
	if (this_is_bss3 != 0) fail |= (1<<0);
	
	// data section copy test
	if (this_is_data[0] != 'H' || this_is_data[6] != 'W') fail |= (1<<1);
	if (this_is_data2 != 5) fail |= (1<<2);
	if (this_is_data3[2] != 0xbe) fail |= (1<<3);
	
	// data section reassign test
	this_is_data2 = 8;
	if (this_is_data2 != 8) fail |= (1<<4);
	// pointer reassign
	this_is_data = &this_is_data2;
	if (*this_is_data != 8) fail |= (1<<5);
	
	// rodata read test
	if (this_is_rodata[0] != 'H' || this_is_rodata[6] != 'w') fail |= (1<<6);
	if (this_is_rodata2 != 7) fail |= (1<<7);
	
	uart_send(fail);
	// 0x30 -- data section assigned to rom
	// 0x0E -- data not copied to ram
	
	while(1) asm("");
} 

// view sections: objdump -t sections.elf
// view contents: objdump -s sections.elf
