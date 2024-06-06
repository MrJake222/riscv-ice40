#define RED		0
#define GREEN	4
#define BLUE	8
#define LED_BASE 	0x10000
#define LED_SET(id, val) (*(volatile unsigned int*)(LED_BASE + id)) = val;
#define LED_GET(id)      (*(volatile unsigned int*)(LED_BASE + id))

void led_set_gamma(int id, int i) {
	LED_SET(id, i*i / 256);
}

int main(void) {
    LED_SET(RED,   0xFF);
    LED_SET(GREEN, 0xFF);
    LED_SET(BLUE,  0xFF);
    
    led_set_gamma(RED,   0x40);
    led_set_gamma(GREEN, 0x40);
    led_set_gamma(BLUE,  0x40);
    
    while(1);
}

__attribute__ ((section(".boot")))
__attribute__ ((naked))
void _start(void) {
	asm("lui sp, 0x10");
	asm("j main");
}
