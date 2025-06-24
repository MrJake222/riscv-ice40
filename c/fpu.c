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

#include <math.h>
#include <stdint.h>

void test(float f1, float f2) {
	float f3 = 0;
	asm("dsqa %[out], %[in1], %[in2]" : [out]"=r"(f3) : [in1]"r"(f1), [in2]"r"(f2));  
	float f3std = (f1-f2)*(f1-f2);
	uint32_t f1u = *(uint32_t*)&f1;
	uint32_t f2u = *(uint32_t*)&f2;
	uint32_t f3u = *(uint32_t*)&f3;
	uint32_t f3stdu = *(uint32_t*)&f3std;
	float d = fabsf(f3-f3std);
	printf("%8.2f h%08x %8.2f h%08x %14.4f h%08x is %14.4f h%08x expt   %s %4.2f %%^3\r\n",
	       f1, f1u, f2, f2u, f3, f3u, f3std, f3stdu, d<1e-3 ? "  " : "NO", d*1000000 / f3std);
}

static uint32_t my_rand_seed;
float my_rand(void) {
    my_rand_seed = my_rand_seed * 1664525 + 1013904223;
    return ((my_rand_seed >> 16) & 0x7FFF) / 32767.0f;
}

float rndf(float magnitude) {
    return (my_rand() * 2.0f - 1.0f) * magnitude;
}

int main(void) {
    printf("fpu test start\r\n");
    
    /*my_rand_seed = 0;
    for (int j=1; j<=1000; j*=10) {
		for (int i=0; i<10; i++) {
			float x = rndf(j), y = rndf(j);
			test(x, y);
		}
	}*/
	
	test(31.23f, 30.92f);
    
    while(1);
}

__attribute__ ((section(".boot")))
__attribute__ ((naked))
void _start(void) {
	asm("lui sp, 0x10");
	asm("j main");
}
