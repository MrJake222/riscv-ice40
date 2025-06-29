#define UART0_BASE  0x10010
#define UART_DATA   (*(volatile unsigned int*)(UART0_BASE + 0))
#define UART_STATUS (*(volatile unsigned int*)(UART0_BASE + 4))
#define UART_HAS_RX     (UART_STATUS & (1<<0))
#define UART_TX_EMPTY   (UART_STATUS & (1<<1))

#include "printf/printf.h"
void _putchar(char data) {
	while (!UART_TX_EMPTY);
	UART_DATA = data;
}

#include <math.h>
#include <stdint.h>

void test(float f1, float f2, float* acc) {
	float f3 = *acc;
	
	asm("dsqa %[out], %[in1], %[in2]" : [out]"+r"(f3) : [in1]"r"(f1), [in2]"r"(f2));  
	float f3std = *acc + (f1-f2)*(f1-f2);

	//float d = fabsf(f3-f3std);

	uint32_t f3u = *(uint32_t*)&f3;
	uint32_t f3stdu = *(uint32_t*)&f3std;
	int d = f3u < f3stdu ? f3stdu - f3u : f3u - f3stdu;
	
	printf_("%14.4f %08lx + (%14.4f %08lx - %14.4f %08lx)^2 = %14.4f %08lx is %14.4f %08lx expt  %s %d\r\n",
				(double)*acc,	*(uint32_t*)acc,
				(double)f1,		*(uint32_t*)&f1,
				(double)f2,		*(uint32_t*)&f2,
				(double)f3,		*(uint32_t*)&f3,
				(double)f3std,	*(uint32_t*)&f3std,
				d<5 ? "  " : "NO", d);
		   
	*acc = f3;
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
	
	float acc = 0;
	my_rand_seed = 0;
	for (int j=1; j<=1000; j*=10) {
		for (int i=0; i<10; i++) {
			float x = rndf(j), y = rndf(j);
			test(x, y, &acc);
		}
	}
	
	//test(31.23f, 30.92f);
	
	while(1);
}

__attribute__ ((section(".boot")))
__attribute__ ((naked))
void _start(void) {
	asm("lui sp, 0x10");
	asm("j main");
}
