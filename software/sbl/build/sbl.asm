
build/sbl.elf:     file format elf32-littleriscv


Disassembly of section .vector:

80000000 <crtStart>:

    .section	.start_jump,"ax",@progbits
crtStart:
  //long jump to allow crtInit to be anywhere
  //do it always in 12 bytes
  lui x2,       %hi(crtInit)
80000000:	80000137          	lui	sp,0x80000
  addi x2, x2,  %lo(crtInit)
80000004:	0b010113          	addi	sp,sp,176 # 800000b0 <__global_pointer$+0xffffe8c8>
  jalr x1,x2
80000008:	000100e7          	jalr	sp
  nop
8000000c:	00000013          	nop
	...

80000020 <trap_entry>:
.section .text

.global  trap_entry
.align 5
trap_entry:
  sw x1,  - 1*4(sp)
80000020:	fe112e23          	sw	ra,-4(sp)
  sw x5,  - 2*4(sp)
80000024:	fe512c23          	sw	t0,-8(sp)
  sw x6,  - 3*4(sp)
80000028:	fe612a23          	sw	t1,-12(sp)
  sw x7,  - 4*4(sp)
8000002c:	fe712823          	sw	t2,-16(sp)
  sw x10, - 5*4(sp)
80000030:	fea12623          	sw	a0,-20(sp)
  sw x11, - 6*4(sp)
80000034:	feb12423          	sw	a1,-24(sp)
  sw x12, - 7*4(sp)
80000038:	fec12223          	sw	a2,-28(sp)
  sw x13, - 8*4(sp)
8000003c:	fed12023          	sw	a3,-32(sp)
  sw x14, - 9*4(sp)
80000040:	fce12e23          	sw	a4,-36(sp)
  sw x15, -10*4(sp)
80000044:	fcf12c23          	sw	a5,-40(sp)
  sw x16, -11*4(sp)
80000048:	fd012a23          	sw	a6,-44(sp)
  sw x17, -12*4(sp)
8000004c:	fd112823          	sw	a7,-48(sp)
  sw x28, -13*4(sp)
80000050:	fdc12623          	sw	t3,-52(sp)
  sw x29, -14*4(sp)
80000054:	fdd12423          	sw	t4,-56(sp)
  sw x30, -15*4(sp)
80000058:	fde12223          	sw	t5,-60(sp)
  sw x31, -16*4(sp)
8000005c:	fdf12023          	sw	t6,-64(sp)
  addi sp,sp,-16*4
80000060:	fc010113          	addi	sp,sp,-64
  call irqCallback
80000064:	0d4010ef          	jal	ra,80001138 <irqCallback>
  lw x1 , 15*4(sp)
80000068:	03c12083          	lw	ra,60(sp)
  lw x5,  14*4(sp)
8000006c:	03812283          	lw	t0,56(sp)
  lw x6,  13*4(sp)
80000070:	03412303          	lw	t1,52(sp)
  lw x7,  12*4(sp)
80000074:	03012383          	lw	t2,48(sp)
  lw x10, 11*4(sp)
80000078:	02c12503          	lw	a0,44(sp)
  lw x11, 10*4(sp)
8000007c:	02812583          	lw	a1,40(sp)
  lw x12,  9*4(sp)
80000080:	02412603          	lw	a2,36(sp)
  lw x13,  8*4(sp)
80000084:	02012683          	lw	a3,32(sp)
  lw x14,  7*4(sp)
80000088:	01c12703          	lw	a4,28(sp)
  lw x15,  6*4(sp)
8000008c:	01812783          	lw	a5,24(sp)
  lw x16,  5*4(sp)
80000090:	01412803          	lw	a6,20(sp)
  lw x17,  4*4(sp)
80000094:	01012883          	lw	a7,16(sp)
  lw x28,  3*4(sp)
80000098:	00c12e03          	lw	t3,12(sp)
  lw x29,  2*4(sp)
8000009c:	00812e83          	lw	t4,8(sp)
  lw x30,  1*4(sp)
800000a0:	00412f03          	lw	t5,4(sp)
  lw x31,  0*4(sp)
800000a4:	00012f83          	lw	t6,0(sp)
  addi sp,sp,16*4
800000a8:	04010113          	addi	sp,sp,64
  mret
800000ac:	30200073          	mret

800000b0 <crtInit>:


crtInit:
  .option push
  .option norelax
  la gp, __global_pointer$
800000b0:	00001197          	auipc	gp,0x1
800000b4:	73818193          	addi	gp,gp,1848 # 800017e8 <__global_pointer$>
  .option pop
  la sp, _stack_start
800000b8:	00001117          	auipc	sp,0x1
800000bc:	ee810113          	addi	sp,sp,-280 # 80000fa0 <_stack_start>

800000c0 <bss_init>:

bss_init:
  la a0, _bss_start
800000c0:	00001517          	auipc	a0,0x1
800000c4:	f2850513          	addi	a0,a0,-216 # 80000fe8 <_bss_end>
  la a1, _bss_end
800000c8:	00001597          	auipc	a1,0x1
800000cc:	f2058593          	addi	a1,a1,-224 # 80000fe8 <_bss_end>

800000d0 <bss_loop>:
bss_loop:
  beq a0,a1,bss_done
800000d0:	00b50863          	beq	a0,a1,800000e0 <bss_done>
  sw zero,0(a0)
800000d4:	00052023          	sw	zero,0(a0)
  add a0,a0,4
800000d8:	00450513          	addi	a0,a0,4
  j bss_loop
800000dc:	ff5ff06f          	j	800000d0 <bss_loop>

800000e0 <bss_done>:
bss_done:

ctors_init:
  la a0, _ctors_start
800000e0:	c4018513          	addi	a0,gp,-960 # 80001428 <_ctors_end>
  addi sp,sp,-4
800000e4:	ffc10113          	addi	sp,sp,-4

800000e8 <ctors_loop>:
ctors_loop:
  la a1, _ctors_end
800000e8:	c4018593          	addi	a1,gp,-960 # 80001428 <_ctors_end>
  beq a0,a1,ctors_done
800000ec:	00b50e63          	beq	a0,a1,80000108 <ctors_done>
  lw a3,0(a0)
800000f0:	00052683          	lw	a3,0(a0)
  add a0,a0,4
800000f4:	00450513          	addi	a0,a0,4
  sw a0,0(sp)
800000f8:	00a12023          	sw	a0,0(sp)
  jalr  a3
800000fc:	000680e7          	jalr	a3
  lw a0,0(sp)
80000100:	00012503          	lw	a0,0(sp)
  j ctors_loop
80000104:	fe5ff06f          	j	800000e8 <ctors_loop>

80000108 <ctors_done>:
ctors_done:
  addi sp,sp,4
80000108:	00410113          	addi	sp,sp,4


  li a0, 0x880     //880 enable timer + external interrupts
8000010c:	00001537          	lui	a0,0x1
80000110:	88050513          	addi	a0,a0,-1920 # 880 <_stack_size+0xe2>
  csrw mie,a0
80000114:	30451073          	csrw	mie,a0
  li a0, 0x1808     //1808 enable interrupts
80000118:	00002537          	lui	a0,0x2
8000011c:	80850513          	addi	a0,a0,-2040 # 1808 <_stack_size+0x106a>
  csrw mstatus,a0
80000120:	30051073          	csrw	mstatus,a0

  call main
80000124:	018010ef          	jal	ra,8000113c <end>

80000128 <infinitLoop>:
infinitLoop:
  j infinitLoop
80000128:	0000006f          	j	80000128 <infinitLoop>
	...

80000134 <print_impl>:
	enum UartStop stop;
	uint32_t clockDivider;
} Uart_Config;

static uint32_t uart_writeAvailability(Uart_Reg *reg){
	return (reg->STATUS >> 16) & 0xFF;
80000134:	f00106b7          	lui	a3,0xf0010
#define CODE_TO_KEEP __attribute__ ((section ("code_to_keep")))
#define DATA_TO_KEEP __attribute__ ((section ("data_to_keep")))
#include "tesicchip1.h"

CODE_TO_KEEP void print_impl(const char*msg){
	while(*msg){
80000138:	00054703          	lbu	a4,0(a0)
8000013c:	00071463          	bnez	a4,80000144 <print_impl+0x10>
		uart_write(UART,*msg);
		msg++;
	}
}
80000140:	00008067          	ret
80000144:	0046a783          	lw	a5,4(a3) # f0010004 <__global_pointer$+0x7000e81c>
80000148:	0107d793          	srli	a5,a5,0x10
8000014c:	0ff7f793          	andi	a5,a5,255
static uint32_t uart_readOccupancy(Uart_Reg *reg){
	return reg->STATUS >> 24;
}

static void uart_write(Uart_Reg *reg, uint32_t data){
	while(uart_writeAvailability(reg) == 0);
80000150:	fe078ae3          	beqz	a5,80000144 <print_impl+0x10>
	reg->DATA = data;
80000154:	00e6a023          	sw	a4,0(a3)
		msg++;
80000158:	00150513          	addi	a0,a0,1
8000015c:	fddff06f          	j	80000138 <print_impl+0x4>

80000160 <msg>:
80000160:	80000fdc                                ....

Disassembly of section .memory:

80000fe8 <println>:
      l++;
  }
  print(resptr);
}

static void println(const char*msg){
80000fe8:	ff010113          	addi	sp,sp,-16
80000fec:	00112623          	sw	ra,12(sp)
static void print(const char*msg){if(!print_enabled) return;print_impl(msg);}
80000ff0:	944ff0ef          	jal	ra,80000134 <print_impl>
  if(!print_enabled) return;
  print(msg);print("\n");
}
80000ff4:	00c12083          	lw	ra,12(sp)
static void print(const char*msg){if(!print_enabled) return;print_impl(msg);}
80000ff8:	80001537          	lui	a0,0x80001
80000ffc:	fd850513          	addi	a0,a0,-40 # 80000fd8 <__global_pointer$+0xfffff7f0>
}
80001000:	01010113          	addi	sp,sp,16
static void print(const char*msg){if(!print_enabled) return;print_impl(msg);}
80001004:	930ff06f          	j	80000134 <print_impl>

80001008 <inc_gpio>:
//#include "satl.h"

//#include "tesic_api.h"

void inc_gpio(void){
	GPIO_A->OUTPUT = 0x0F & (GPIO_A->OUTPUT + 1);
80001008:	f0000737          	lui	a4,0xf0000
8000100c:	00472783          	lw	a5,4(a4) # f0000004 <__global_pointer$+0x6fffe81c>
80001010:	00178793          	addi	a5,a5,1
80001014:	00f7f793          	andi	a5,a5,15
80001018:	00f72223          	sw	a5,4(a4)
}
8000101c:	00008067          	ret

80001020 <sbl_rx8>:
	return reg->STATUS >> 24;
80001020:	f0010737          	lui	a4,0xf0010
80001024:	00472783          	lw	a5,4(a4) # f0010004 <__global_pointer$+0x7000e81c>
80001028:	0187d793          	srli	a5,a5,0x18

CODE_TO_KEEP static void uart_read(Uart_Reg *reg, uint8_t *data){
	while(uart_readOccupancy(reg) == 0);
8000102c:	fe078ce3          	beqz	a5,80001024 <sbl_rx8+0x4>
	*data = reg->DATA;
80001030:	00072783          	lw	a5,0(a4)
80001034:	00f50023          	sb	a5,0(a0)
    inc_gpio();
80001038:	fd1ff06f          	j	80001008 <inc_gpio>

8000103c <sbl_rx>:
	f();
}
#endif

//utils, com is always done in little endian
static void sbl_rx(void*dat, unsigned int len){
8000103c:	ff010113          	addi	sp,sp,-16
80001040:	00812423          	sw	s0,8(sp)
80001044:	00912223          	sw	s1,4(sp)
80001048:	00112623          	sw	ra,12(sp)
8000104c:	00050413          	mv	s0,a0
80001050:	00b504b3          	add	s1,a0,a1
	uint8_t*dat8 = (uint8_t*)dat;
	for(unsigned int i=0;i<len;i++) sbl_rx8(dat8+i);
80001054:	00040513          	mv	a0,s0
80001058:	00140413          	addi	s0,s0,1
8000105c:	fc5ff0ef          	jal	ra,80001020 <sbl_rx8>
80001060:	fe849ae3          	bne	s1,s0,80001054 <sbl_rx+0x18>
}
80001064:	00c12083          	lw	ra,12(sp)
80001068:	00812403          	lw	s0,8(sp)
8000106c:	00412483          	lw	s1,4(sp)
80001070:	01010113          	addi	sp,sp,16
80001074:	00008067          	ret

80001078 <sbl_tx8>:
	return (reg->STATUS >> 16) & 0xFF;
80001078:	f0010737          	lui	a4,0xf0010
8000107c:	00472783          	lw	a5,4(a4) # f0010004 <__global_pointer$+0x7000e81c>
80001080:	0107d793          	srli	a5,a5,0x10
80001084:	0ff7f793          	andi	a5,a5,255
	while(uart_writeAvailability(reg) == 0);
80001088:	fe078ae3          	beqz	a5,8000107c <sbl_tx8+0x4>
	reg->DATA = data;
8000108c:	00a72023          	sw	a0,0(a4)
void sbl_rx8(uint8_t*dat){
	uart_read(UART,dat);
}
void sbl_tx8(uint8_t dat){
	uart_write(UART,dat);
}
80001090:	00008067          	ret

80001094 <sbl_read8>:
void sbl_read8(uint8_t*dat, uint32_t addr)		{*dat = *((uint8_t*)addr);}
80001094:	0005c783          	lbu	a5,0(a1)
80001098:	00f50023          	sb	a5,0(a0)
8000109c:	00008067          	ret

800010a0 <sbl_write8>:
void sbl_write8(uint8_t dat, uint32_t addr)		{*((uint8_t*)addr) = dat;}
800010a0:	00a58023          	sb	a0,0(a1)
800010a4:	00008067          	ret

800010a8 <sbl_read16>:
void sbl_read16(uint16_t*dat, uint32_t addr)	{*dat = *((uint16_t*)addr);}
800010a8:	0005d783          	lhu	a5,0(a1)
800010ac:	00f51023          	sh	a5,0(a0)
800010b0:	00008067          	ret

800010b4 <sbl_write16>:
void sbl_write16(uint16_t dat, uint32_t addr)	{*((uint16_t*)addr) = dat;}
800010b4:	00a59023          	sh	a0,0(a1)
800010b8:	00008067          	ret

800010bc <sbl_read32>:
void sbl_read32(uint32_t*dat, uint32_t addr)	{*dat = *((uint32_t*)addr);}
800010bc:	0005a783          	lw	a5,0(a1)
800010c0:	00f52023          	sw	a5,0(a0)
800010c4:	00008067          	ret

800010c8 <sbl_write32>:
void sbl_write32(uint32_t dat, uint32_t addr)	{*((uint32_t*)addr) = dat;}
800010c8:	00a5a023          	sw	a0,0(a1)
800010cc:	00008067          	ret

800010d0 <sbl_exec>:
	f();
800010d0:	00050313          	mv	t1,a0
800010d4:	00030067          	jr	t1

800010d8 <exec_target>:

#define NUM_ELEMS(a) (sizeof(a)/sizeof 0[a])


void exec_target(void){
    GPIO_A->OUTPUT = 0x0000000A;
800010d8:	00a00713          	li	a4,10
800010dc:	f00007b7          	lui	a5,0xf0000
800010e0:	00e7a223          	sw	a4,4(a5) # f0000004 <__global_pointer$+0x6fffe81c>
	return (reg->STATUS >> 16) & 0xFF;
800010e4:	f0010737          	lui	a4,0xf0010
800010e8:	00472783          	lw	a5,4(a4) # f0010004 <__global_pointer$+0x7000e81c>
800010ec:	0107d793          	srli	a5,a5,0x10
800010f0:	0ff7f793          	andi	a5,a5,255
	while(uart_writeAvailability(reg) == 0);
800010f4:	fe078ae3          	beqz	a5,800010e8 <exec_target+0x10>
	reg->DATA = data;
800010f8:	09000793          	li	a5,144
800010fc:	00f72023          	sw	a5,0(a4)
	return (reg->STATUS >> 16) & 0xFF;
80001100:	f0010737          	lui	a4,0xf0010
80001104:	00472783          	lw	a5,4(a4) # f0010004 <__global_pointer$+0x7000e81c>
80001108:	0107d793          	srli	a5,a5,0x10
8000110c:	0ff7f793          	andi	a5,a5,255
	while(uart_writeAvailability(reg) == 0);
80001110:	fe078ae3          	beqz	a5,80001104 <exec_target+0x2c>
	reg->DATA = data;
80001114:	00072023          	sw	zero,0(a4)
    uart_write(UART,0x90);
    uart_write(UART,0x00);
    GPIO_A->OUTPUT = 0x0000000C;
80001118:	f00007b7          	lui	a5,0xf0000
8000111c:	00c00713          	li	a4,12
80001120:	00e7a223          	sw	a4,4(a5) # f0000004 <__global_pointer$+0x6fffe81c>
}
80001124:	00008067          	ret

80001128 <wait_gpo>:
void wait_gpo(Gpio_Reg*gpio, uint32_t mask, uint32_t val){
  while((gpio->OUTPUT & mask) != val);
80001128:	00452783          	lw	a5,4(a0)
8000112c:	00b7f7b3          	and	a5,a5,a1
80001130:	fec79ce3          	bne	a5,a2,80001128 <wait_gpo>
}
80001134:	00008067          	ret

80001138 <irqCallback>:
	sbl_main();
	while(1);
}

void irqCallback(){
}
80001138:	00008067          	ret

Disassembly of section .text.startup:

8000113c <main>:
void main() {
8000113c:	fb010113          	addi	sp,sp,-80
80001140:	04812423          	sw	s0,72(sp)
80001144:	04112623          	sw	ra,76(sp)
80001148:	04912223          	sw	s1,68(sp)
8000114c:	05212023          	sw	s2,64(sp)
80001150:	03312e23          	sw	s3,60(sp)
80001154:	03412c23          	sw	s4,56(sp)
80001158:	03512a23          	sw	s5,52(sp)
8000115c:	03612823          	sw	s6,48(sp)
80001160:	03712623          	sw	s7,44(sp)
80001164:	03812423          	sw	s8,40(sp)
80001168:	03912223          	sw	s9,36(sp)
8000116c:	03a12023          	sw	s10,32(sp)
80001170:	01b12e23          	sw	s11,28(sp)
  GPIO_A->OUTPUT = 0x00000000;
80001174:	f0000437          	lui	s0,0xf0000
	GPIO_A->OUTPUT_ENABLE = 0x0000000F;
80001178:	00f00793          	li	a5,15
  GPIO_A->OUTPUT = 0x00000000;
8000117c:	00042223          	sw	zero,4(s0) # f0000004 <__global_pointer$+0x6fffe81c>
  println("Hello from SOC 1");
80001180:	80001537          	lui	a0,0x80001
	GPIO_A->OUTPUT_ENABLE = 0x0000000F;
80001184:	00f42423          	sw	a5,8(s0)
  println("Hello from SOC 1");
80001188:	fa050513          	addi	a0,a0,-96 # 80000fa0 <__global_pointer$+0xfffff7b8>
8000118c:	e5dff0ef          	jal	ra,80000fe8 <_bss_end>
  GPIO_A->OUTPUT = 0x00000001;
80001190:	00100793          	li	a5,1
80001194:	00f42223          	sw	a5,4(s0)
  while((gpio->OUTPUT & mask) != val);
80001198:	00442783          	lw	a5,4(s0)
8000119c:	0017f793          	andi	a5,a5,1
800011a0:	fe079ce3          	bnez	a5,80001198 <main+0x5c>
  println("Hello from SOC 2");
800011a4:	80001537          	lui	a0,0x80001
800011a8:	fb450513          	addi	a0,a0,-76 # 80000fb4 <__global_pointer$+0xfffff7cc>
800011ac:	e3dff0ef          	jal	ra,80000fe8 <_bss_end>
	GPIO_A->OUTPUT = 0x00000005;
800011b0:	00500793          	li	a5,5
800011b4:	00f42223          	sw	a5,4(s0)
  while((gpio->OUTPUT & mask) != val);
800011b8:	f0000437          	lui	s0,0xf0000
800011bc:	00442783          	lw	a5,4(s0) # f0000004 <__global_pointer$+0x6fffe81c>
800011c0:	0017f793          	andi	a5,a5,1
800011c4:	fe079ce3          	bnez	a5,800011bc <main+0x80>
	println("A");
800011c8:	80001537          	lui	a0,0x80001
800011cc:	fc850513          	addi	a0,a0,-56 # 80000fc8 <__global_pointer$+0xfffff7e0>
800011d0:	e19ff0ef          	jal	ra,80000fe8 <_bss_end>
  GPIO_A->OUTPUT = 0x00000001;
800011d4:	00100793          	li	a5,1
  println("Entering SBL\n");
800011d8:	80001537          	lui	a0,0x80001
		addr = base+offset;
		access_unit = cmd & 0xFF;
		len = compute_len(len,access_unit);

		status = SBL_OK;
		switch(cmd){
800011dc:	00001937          	lui	s2,0x1
  GPIO_A->OUTPUT = 0x00000001;
800011e0:	00f42223          	sw	a5,4(s0)
  println("Entering SBL\n");
800011e4:	fcc50513          	addi	a0,a0,-52 # 80000fcc <__global_pointer$+0xfffff7e4>
800011e8:	e01ff0ef          	jal	ra,80000fe8 <_bss_end>
	uint32_t base=0;
800011ec:	00000993          	li	s3,0
		switch(cmd){
800011f0:	b0090b13          	addi	s6,s2,-1280 # b00 <_stack_size+0x362>
800011f4:	c1090b93          	addi	s7,s2,-1008
		sbl_rx(&cmd,2);
800011f8:	00200593          	li	a1,2
800011fc:	00810513          	addi	a0,sp,8
80001200:	e3dff0ef          	jal	ra,8000103c <sbl_rx>
		sbl_rx(&offset,2);
80001204:	00200593          	li	a1,2
80001208:	00a10513          	addi	a0,sp,10
8000120c:	e31ff0ef          	jal	ra,8000103c <sbl_rx>
		sbl_rx8(&len);
80001210:	00710513          	addi	a0,sp,7
80001214:	e0dff0ef          	jal	ra,80001020 <sbl_rx8>
		access_unit = cmd & 0xFF;
80001218:	00815783          	lhu	a5,8(sp)
		addr = base+offset;
8000121c:	00a15403          	lhu	s0,10(sp)
	switch(access_unit){
80001220:	01000693          	li	a3,16
80001224:	0ff7f493          	andi	s1,a5,255
		addr = base+offset;
80001228:	01340433          	add	s0,s0,s3
		len = compute_len(len,access_unit);
8000122c:	00714703          	lbu	a4,7(sp)
	switch(access_unit){
80001230:	06d48463          	beq	s1,a3,80001298 <main+0x15c>
80001234:	02000693          	li	a3,32
80001238:	06d48463          	beq	s1,a3,800012a0 <main+0x164>
		len = compute_len(len,access_unit);
8000123c:	00e103a3          	sb	a4,7(sp)
		switch(cmd){
80001240:	1b678463          	beq	a5,s6,800013e8 <main+0x2ac>
80001244:	06fb6263          	bltu	s6,a5,800012a8 <main+0x16c>
80001248:	a1090713          	addi	a4,s2,-1520
8000124c:	00e78a63          	beq	a5,a4,80001260 <main+0x124>
80001250:	a2090713          	addi	a4,s2,-1504
80001254:	00e78663          	beq	a5,a4,80001260 <main+0x124>
80001258:	a0890713          	addi	a4,s2,-1528
8000125c:	04e79e63          	bne	a5,a4,800012b8 <main+0x17c>
		case SBL_CMD_READ_8:
		case SBL_CMD_READ_16:
		case SBL_CMD_READ_32:
			sbl_tx8(cmd>>8);//send ISO7816 ACK
80001260:	00a00513          	li	a0,10
80001264:	e15ff0ef          	jal	ra,80001078 <sbl_tx8>
					sbl_tx8(buf>>8);
					sbl_tx8(buf>>16);
					sbl_tx8(buf>>24);
					break;
				}
				addr+=access_unit>>3;
80001268:	0034dc13          	srli	s8,s1,0x3
			for(unsigned int i=0;i<len;i++){
8000126c:	00000a93          	li	s5,0
				switch(access_unit){
80001270:	01000c93          	li	s9,16
80001274:	02000d13          	li	s10,32
80001278:	00800d93          	li	s11,8
			for(unsigned int i=0;i<len;i++){
8000127c:	00714783          	lbu	a5,7(sp)
80001280:	06fae063          	bltu	s5,a5,800012e0 <main+0x1a4>
		status = SBL_OK;
80001284:	09000513          	li	a0,144
	for(unsigned int i=0;i<len;i++) sbl_tx8(*(dat8+i));
80001288:	df1ff0ef          	jal	ra,80001078 <sbl_tx8>
8000128c:	00000513          	li	a0,0
80001290:	de9ff0ef          	jal	ra,80001078 <sbl_tx8>
80001294:	f65ff06f          	j	800011f8 <main+0xbc>
	case 16: len = len>>1;break;
80001298:	00175713          	srli	a4,a4,0x1
8000129c:	fa1ff06f          	j	8000123c <main+0x100>
	case 32: len = len>>2;break;
800012a0:	00275713          	srli	a4,a4,0x2
800012a4:	f99ff06f          	j	8000123c <main+0x100>
		switch(cmd){
800012a8:	0b778663          	beq	a5,s7,80001354 <main+0x218>
800012ac:	00fbea63          	bltu	s7,a5,800012c0 <main+0x184>
800012b0:	c0890713          	addi	a4,s2,-1016
800012b4:	0ae78063          	beq	a5,a4,80001354 <main+0x218>
			break;
		case SBL_CMD_EXEC:
			sbl_exec(addr);
			break;
		default:
			status = SBL_KO;
800012b8:	06400513          	li	a0,100
800012bc:	fcdff06f          	j	80001288 <main+0x14c>
		switch(cmd){
800012c0:	00001737          	lui	a4,0x1
800012c4:	c2070713          	addi	a4,a4,-992 # c20 <_stack_size+0x482>
800012c8:	08e78663          	beq	a5,a4,80001354 <main+0x218>
800012cc:	e0090713          	addi	a4,s2,-512
800012d0:	fee794e3          	bne	a5,a4,800012b8 <main+0x17c>
			sbl_exec(addr);
800012d4:	00040513          	mv	a0,s0
800012d8:	df9ff0ef          	jal	ra,800010d0 <sbl_exec>
800012dc:	fa9ff06f          	j	80001284 <main+0x148>
				switch(access_unit){
800012e0:	03948463          	beq	s1,s9,80001308 <main+0x1cc>
800012e4:	05a48263          	beq	s1,s10,80001328 <main+0x1ec>
800012e8:	01b49a63          	bne	s1,s11,800012fc <main+0x1c0>
void sbl_read8(uint8_t*dat, uint32_t addr)		{*dat = *((uint8_t*)addr);}
800012ec:	00044783          	lbu	a5,0(s0)
800012f0:	00f10623          	sb	a5,12(sp)
					sbl_tx8(buf);
800012f4:	0ff7f513          	andi	a0,a5,255
					sbl_tx8(buf>>24);
800012f8:	d81ff0ef          	jal	ra,80001078 <sbl_tx8>
				addr+=access_unit>>3;
800012fc:	01840433          	add	s0,s0,s8
			for(unsigned int i=0;i<len;i++){
80001300:	001a8a93          	addi	s5,s5,1
80001304:	f79ff06f          	j	8000127c <main+0x140>
void sbl_read16(uint16_t*dat, uint32_t addr)	{*dat = *((uint16_t*)addr);}
80001308:	00045783          	lhu	a5,0(s0)
8000130c:	00f11623          	sh	a5,12(sp)
					sbl_tx8(buf);
80001310:	00c12a03          	lw	s4,12(sp)
80001314:	0ffa7513          	andi	a0,s4,255
80001318:	d61ff0ef          	jal	ra,80001078 <sbl_tx8>
					sbl_tx8(buf>>8);
8000131c:	008a5513          	srli	a0,s4,0x8
80001320:	0ff57513          	andi	a0,a0,255
80001324:	fd5ff06f          	j	800012f8 <main+0x1bc>
void sbl_read32(uint32_t*dat, uint32_t addr)	{*dat = *((uint32_t*)addr);}
80001328:	00042a03          	lw	s4,0(s0)
					sbl_tx8(buf);
8000132c:	0ffa7513          	andi	a0,s4,255
80001330:	d49ff0ef          	jal	ra,80001078 <sbl_tx8>
					sbl_tx8(buf>>8);
80001334:	008a5513          	srli	a0,s4,0x8
80001338:	0ff57513          	andi	a0,a0,255
8000133c:	d3dff0ef          	jal	ra,80001078 <sbl_tx8>
					sbl_tx8(buf>>16);
80001340:	010a5513          	srli	a0,s4,0x10
80001344:	0ff57513          	andi	a0,a0,255
80001348:	d31ff0ef          	jal	ra,80001078 <sbl_tx8>
					sbl_tx8(buf>>24);
8000134c:	018a5513          	srli	a0,s4,0x18
80001350:	fa9ff06f          	j	800012f8 <main+0x1bc>
			sbl_tx8(cmd>>8);//send ISO7816 ACK
80001354:	00c00513          	li	a0,12
80001358:	d21ff0ef          	jal	ra,80001078 <sbl_tx8>
				addr+=access_unit>>3;
8000135c:	0034da93          	srli	s5,s1,0x3
			for(unsigned int i=0;i<len;i++){
80001360:	00000a13          	li	s4,0
				switch(access_unit){
80001364:	01000c13          	li	s8,16
80001368:	02000c93          	li	s9,32
8000136c:	00800d13          	li	s10,8
			for(unsigned int i=0;i<len;i++){
80001370:	00714783          	lbu	a5,7(sp)
80001374:	f0fa78e3          	bleu	a5,s4,80001284 <main+0x148>
				switch(access_unit){
80001378:	03848463          	beq	s1,s8,800013a0 <main+0x264>
8000137c:	03948e63          	beq	s1,s9,800013b8 <main+0x27c>
80001380:	01a49a63          	bne	s1,s10,80001394 <main+0x258>
					sbl_rx8(buf8);
80001384:	00c10513          	addi	a0,sp,12
80001388:	c99ff0ef          	jal	ra,80001020 <sbl_rx8>
					sbl_write8(buf8[0],addr);
8000138c:	00c14783          	lbu	a5,12(sp)
void sbl_write8(uint8_t dat, uint32_t addr)		{*((uint8_t*)addr) = dat;}
80001390:	00f40023          	sb	a5,0(s0)
				addr+=access_unit>>3;
80001394:	01540433          	add	s0,s0,s5
			for(unsigned int i=0;i<len;i++){
80001398:	001a0a13          	addi	s4,s4,1
8000139c:	fd5ff06f          	j	80001370 <main+0x234>
					sbl_rx(buf8,2);
800013a0:	00200593          	li	a1,2
800013a4:	00c10513          	addi	a0,sp,12
800013a8:	c95ff0ef          	jal	ra,8000103c <sbl_rx>
800013ac:	00c15783          	lhu	a5,12(sp)
void sbl_write16(uint16_t dat, uint32_t addr)	{*((uint16_t*)addr) = dat;}
800013b0:	00f41023          	sh	a5,0(s0)
800013b4:	fe1ff06f          	j	80001394 <main+0x258>
					sbl_rx(buf8,4);
800013b8:	00400593          	li	a1,4
800013bc:	00c10513          	addi	a0,sp,12
800013c0:	c7dff0ef          	jal	ra,8000103c <sbl_rx>
					buf = (buf<<8) | buf8[2];
800013c4:	00e15783          	lhu	a5,14(sp)
					buf = (buf<<8) | buf8[1];
800013c8:	00879713          	slli	a4,a5,0x8
800013cc:	00d14783          	lbu	a5,13(sp)
800013d0:	00e7e7b3          	or	a5,a5,a4
					buf = (buf<<8) | buf8[0];
800013d4:	00c14703          	lbu	a4,12(sp)
800013d8:	00879793          	slli	a5,a5,0x8
800013dc:	00f767b3          	or	a5,a4,a5
void sbl_write32(uint32_t dat, uint32_t addr)	{*((uint32_t*)addr) = dat;}
800013e0:	00f42023          	sw	a5,0(s0)
800013e4:	fb1ff06f          	j	80001394 <main+0x258>
			if(4==len){
800013e8:	00400793          	li	a5,4
				status = SBL_KO;
800013ec:	06400513          	li	a0,100
			if(4==len){
800013f0:	e8f71ce3          	bne	a4,a5,80001288 <main+0x14c>
				sbl_tx8(cmd>>8);//send ISO7816 ACK
800013f4:	00b00513          	li	a0,11
800013f8:	c81ff0ef          	jal	ra,80001078 <sbl_tx8>
				sbl_rx(buf,4);
800013fc:	00400593          	li	a1,4
80001400:	00c10513          	addi	a0,sp,12
80001404:	c39ff0ef          	jal	ra,8000103c <sbl_rx>
				base = (base<<8) | buf[2];
80001408:	00e15783          	lhu	a5,14(sp)
				base = (base<<8) | buf[1];
8000140c:	00d14983          	lbu	s3,13(sp)
80001410:	00879793          	slli	a5,a5,0x8
80001414:	00f9e9b3          	or	s3,s3,a5
				base = (base<<8) | buf[0];
80001418:	00899793          	slli	a5,s3,0x8
8000141c:	00c14983          	lbu	s3,12(sp)
80001420:	00f9e9b3          	or	s3,s3,a5
80001424:	e61ff06f          	j	80001284 <main+0x148>
