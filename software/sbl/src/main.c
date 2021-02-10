#include "stddefs.h"
#include <stdint.h>

#define CODE_TO_KEEP __attribute__ ((section ("code_to_keep")))
#define DATA_TO_KEEP __attribute__ ((section ("data_to_keep")))
#include "tesicchip1.h"

CODE_TO_KEEP void print_impl(const char*msg){
	while(*msg){
		uart_write(UART,*msg);
		msg++;
	}
}
#include "print.h"
#include "assert_print.h"

//#include "satl_tesic_apb_master.h"
//#include "satl.h"

//#include "tesic_api.h"

void inc_gpio(void){
	GPIO_A->OUTPUT = 0x0F & (GPIO_A->OUTPUT + 1);
}

CODE_TO_KEEP static void uart_read(Uart_Reg *reg, uint8_t *data){
	while(uart_readOccupancy(reg) == 0);
	*data = reg->DATA;
    inc_gpio();
}


CODE_TO_KEEP static void rx_buf(void *dst, uint32_t size){
    uint8_t*dst8=(uint8_t*)dst;
    for(uint32_t i=0;i<size;i++){
        uart_read(UART, dst8++);
    }
}

CODE_TO_KEEP static uint32_t rx_u32(void){
    uint32_t out;
    rx_buf(&out,sizeof(out));
    return out;
}

#define RAM_BASE   ((void*)0x80000000)
#define CODE_TO_KEEP_SIZE 0x400
#define ERASE_BASE (RAM_BASE+CODE_TO_KEEP_SIZE)
#define SECURE_BOOT_AREA_OFFSET 0x5000
#define ERASE_SIZE (SECURE_BOOT_AREA_OFFSET-CODE_TO_KEEP_SIZE)
#define SECURE_BOOT_IMAGE_BASE (RAM_BASE+SECURE_BOOT_AREA_OFFSET)

typedef void (*void_func_t)(void);
DATA_TO_KEEP const char*const msg = "Erase done";

void sbl_rx8(uint8_t*dat){
	uart_read(UART,dat);
}
void sbl_tx8(uint8_t dat){
	uart_write(UART,dat);
}
#include "sbl.h"


#define NUM_ELEMS(a) (sizeof(a)/sizeof 0[a])


void exec_target(void){
    GPIO_A->OUTPUT = 0x0000000A;
    uart_write(UART,0x90);
    uart_write(UART,0x00);
    GPIO_A->OUTPUT = 0x0000000C;
}

void main() {
	GPIO_A->OUTPUT_ENABLE = 0x0000000F;
	GPIO_A->OUTPUT = 0x00000005;

	println("A");

    GPIO_A->OUTPUT = 0x00000001;
    println("Entering SBL\n");
	sbl_main();
	while(1);
}

void irqCallback(){
}
