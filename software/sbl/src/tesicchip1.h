#ifndef __TESIC_CHIP1_H__
#define __TESIC_CHIP1_H__

#include "timer.h"
#include "prescaler.h"
#include "interrupt.h"
#include "gpio.h"
#include "uart.h"
//#include "drygascon128_apb.h"
#include "tesic_apb.h"
//#include "ipc_tesic_04020r10.h"

#define CORE_HZ 12000000

#define GPIO_A    ((Gpio_Reg*)(0xF0000000))
#define TIMER_PRESCALER ((Prescaler_Reg*)0xF0020000)
#define TIMER_INTERRUPT ((InterruptCtrl_Reg*)0xF0020010)
#define TIMER_A ((Timer_Reg*)0xF0020040)
#define TIMER_B ((Timer_Reg*)0xF0020050)
#define UART      ((Uart_Reg*)(0xF0010000))
#define UART_SAMPLE_PER_BAUD 5
#define DRYGASCON128   ((Drygascon128_Regs*)(0xF0030000))
//#define TESIC ((TESIC_APB_t*)(0xF0040000))
//#define IPC ((IPC_t*)(0xF0050000))
#endif /* __TESIC_CHIP1_H__ */
