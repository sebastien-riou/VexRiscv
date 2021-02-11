#ifndef __SUBSYS_H__
#define __SUBSYS_H__

#include "timer.h"
#include "prescaler.h"
#include "interrupt.h"
#include "gpio.h"

#define CORE_HZ 12000000

#define TIMER_PRESCALER ((Prescaler_Reg*)0xF0020000)
#define TIMER_INTERRUPT ((InterruptCtrl_Reg*)0xF0020010)
#define TIMER_A ((Timer_Reg*)0xF0020040)
#define TIMER_B ((Timer_Reg*)0xF0020050)
#endif /* __SUBSYS_H__ */
