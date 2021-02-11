#include "stddefs.h"
#include <stdint.h>

#define CODE_TO_KEEP __attribute__ ((section ("code_to_keep")))
#define DATA_TO_KEEP __attribute__ ((section ("data_to_keep")))
#include "subsys.h"
#include "uart.h"
#define SOC_GPIO_A    ((Gpio_Reg*)(0x70000000))
#define SOC_UART      ((Uart_Reg*)(0x70010000))

CODE_TO_KEEP void print_impl(const char*msg){
	while(*msg){
		uart_write(SOC_UART,*msg);
		msg++;
	}
}
#include "print.h"

void soc_set_gpo(uint32_t val){
  Gpio_Reg* soc_gpio = ((Gpio_Reg*)(0x70000000));
  soc_gpio->OUTPUT = val;
}

void wait_gpo(Gpio_Reg*gpio, uint32_t mask, uint32_t val){
  while((gpio->OUTPUT & mask) != val);
}

void main() {
  while(SOC_GPIO_A->OUTPUT_ENABLE == 0);
  wait_gpo(SOC_GPIO_A, 1, 1);
  println("Hello from subsys 1");
  SOC_GPIO_A->OUTPUT=2;
  //while(1);
  wait_gpo(SOC_GPIO_A, 1, 1);
  println("Hello from subsys 2");
  SOC_GPIO_A->OUTPUT=4;
  while(1);
  uint32_t cnt=0;
  while(1){
    soc_set_gpo(cnt++);
  }
}

void irqCallback(){
 while(1);
}
