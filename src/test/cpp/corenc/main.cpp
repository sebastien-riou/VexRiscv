#include "VCorenc.h"
#include "VCorenc_Corenc.h"
#ifdef REF
#include "VCorenc_RiscvCore.h"
#endif
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <stdio.h>
#include <iostream>
#include <stdlib.h>
#include <stdint.h>
#include <cstring>
#include <string.h>
#include <iostream>
#include <fstream>
#include <vector>
#include <iomanip>
#include <time.h>
#include <unistd.h>

#include "VCorenc_VexRiscv.h"


#include "../common/framework.h"
#include "../common/jtag.h"
#include "../common/uart.h"

class VexRiscvTracer : public SimElement{
public:
	VCorenc_VexRiscv *cpu;
	ofstream instructionTraces;
	ofstream regTraces;

	VexRiscvTracer(VCorenc_VexRiscv *cpu){
		this->cpu = cpu;
#ifdef TRACE_INSTRUCTION
	instructionTraces.open ("instructionTrace.log");
#endif
#ifdef TRACE_REG
	regTraces.open ("regTraces.log");
#endif
	}



	virtual void preCycle(){
#ifdef TRACE_INSTRUCTION
		if(cpu->writeBack_arbitration_isFiring){
			instructionTraces <<  hex << setw(8) <<  cpu->writeBack_INSTRUCTION << endl;
		}
#endif
#ifdef TRACE_REG
		if(cpu->writeBack_RegFilePlugin_regFileWrite_valid == 1 && cpu->writeBack_RegFilePlugin_regFileWrite_payload_address != 0){
			regTraces << " PC " << hex << setw(8) <<  cpu->writeBack_PC << " : reg[" << dec << setw(2) << (uint32_t)cpu->writeBack_RegFilePlugin_regFileWrite_payload_address << "] = " << hex << setw(8) << cpu->writeBack_RegFilePlugin_regFileWrite_payload_data << endl;
		}

#endif
	}
};




#include <SDL2/SDL.h>
#include <assert.h>
#include <stdint.h>
#include <stdlib.h>


class CorencWorkspace : public Workspace<VCorenc>{
public:
	CorencWorkspace() : Workspace("Corenc"){
		ClockDomain *axiClk = new ClockDomain(&top->io_axiClk,NULL,83333,300000);
		AsyncReset *asyncReset = new AsyncReset(&top->io_asyncReset,50000);
		Jtag *jtag = new Jtag(&top->io_jtag_tms,&top->io_jtag_tdi,&top->io_jtag_tdo,&top->io_jtag_tck,83333*4);
		UartRx *uartRx = new UartRx(&top->io_uart_txd,1.0e12/115200);
		timeProcesses.push_back(axiClk);
		timeProcesses.push_back(asyncReset);
		timeProcesses.push_back(jtag);
		timeProcesses.push_back(uartRx);

		axiClk->add(new VexRiscvTracer(top->Corenc->axi_core_cpu));

		top->io_coreInterrupt = 0;
	}

};


struct timespec timer_start(){
    struct timespec start_time;
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &start_time);
    return start_time;
}

long timer_end(struct timespec start_time){
    struct timespec end_time;
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &end_time);
    uint64_t diffInNanos = end_time.tv_sec*1e9 + end_time.tv_nsec -  start_time.tv_sec*1e9 - start_time.tv_nsec;
    return diffInNanos;
}



int main(int argc, char **argv, char **env) {

	Verilated::randReset(2);
	Verilated::commandArgs(argc, argv);

	printf("BOOT\n");
	timespec startedAt = timer_start();

	CorencWorkspace().run(1e9);

	uint64_t duration = timer_end(startedAt);
	cout << endl << "****************************************************************" << endl;
	cout << "Had simulate " << workspaceCycles << " clock cycles in " << duration*1e-9 << " s (" << workspaceCycles / (duration*1e-9) << " Khz)" << endl;
	cout << "****************************************************************" << endl << endl;


	exit(0);
}
