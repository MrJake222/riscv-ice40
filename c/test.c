#define RED		0
#define GREEN	4
#define BLUE	8

#define LED_BASE 	0x10000

#define LED_SET(id, val) (*(volatile unsigned int*)(LED_BASE + id)) = val;

void led_set_gamma(int id, int i) {
	LED_SET(id, i*i / 256);
}

void delay_ms(int x) {
	int i = 125 * x;
	while(i--) asm("");
}

void breathe(int id) {
	for (int i=255; i>=0; i--) {
		led_set_gamma(id, i);
		delay_ms(5);
	}
	
	for (int i=0; i<256; i++) {
		led_set_gamma(id, i);
		delay_ms(5);
	}
}

int main(void) {
	LED_SET(RED, 255);
	LED_SET(GREEN, 255);
	LED_SET(BLUE, 255);
	
    while(1) {
		breathe(RED);
		breathe(GREEN);
		breathe(BLUE);
	}
}

__attribute__ ((section(".boot")))
__attribute__ ((naked))
void _start(void) {
	asm("j main");
}
