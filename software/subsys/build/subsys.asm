
build/subsys.elf:     file format elf32-littleriscv


Disassembly of section .vector:

80000000 <crtStart>:

    .section	.start_jump,"ax",@progbits
crtStart:
  //long jump to allow crtInit to be anywhere
  //do it always in 12 bytes
  lui x2,       %hi(crtInit)
80000000:	80000137          	lui	sp,0x80000
  addi x2, x2,  %lo(crtInit)
80000004:	0b010113          	addi	sp,sp,176 # 800000b0 <__global_pointer$+0xffffe8e0>
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
80000064:	7a9000ef          	jal	ra,8000100c <irqCallback>
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
800000b4:	72018193          	addi	gp,gp,1824 # 800017d0 <__global_pointer$>
  .option pop
  la sp, _stack_start
800000b8:	00001117          	auipc	sp,0x1
800000bc:	ee810113          	addi	sp,sp,-280 # 80000fa0 <_stack_start>

800000c0 <bss_init>:

bss_init:
  la a0, _bss_start
800000c0:	00001517          	auipc	a0,0x1
800000c4:	f1050513          	addi	a0,a0,-240 # 80000fd0 <_bss_end>
  la a1, _bss_end
800000c8:	00001597          	auipc	a1,0x1
800000cc:	f0858593          	addi	a1,a1,-248 # 80000fd0 <_bss_end>

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
800000e0:	8a418513          	addi	a0,gp,-1884 # 80001074 <_ctors_end>
  addi sp,sp,-4
800000e4:	ffc10113          	addi	sp,sp,-4

800000e8 <ctors_loop>:
ctors_loop:
  la a1, _ctors_end
800000e8:	8a418593          	addi	a1,gp,-1884 # 80001074 <_ctors_end>
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
  //li a0, 0x880     //880 enable timer + external interrupts
  //csrw mie,a0
  //li a0, 0x1808     //1808 enable interrupts
  //csrw mstatus,a0

  call main
8000010c:	705000ef          	jal	ra,80001010 <end>

80000110 <infinitLoop>:
infinitLoop:
  j infinitLoop
80000110:	0000006f          	j	80000110 <infinitLoop>

80000114 <print_impl>:
	enum UartStop stop;
	uint32_t clockDivider;
} Uart_Config;

static uint32_t uart_writeAvailability(Uart_Reg *reg){
	return (reg->STATUS >> 16) & 0xFF;
80000114:	700106b7          	lui	a3,0x70010
#include "uart.h"
#define SOC_GPIO_A    ((Gpio_Reg*)(0x70000000))
#define SOC_UART      ((Uart_Reg*)(0x70010000))

CODE_TO_KEEP void print_impl(const char*msg){
	while(*msg){
80000118:	00054703          	lbu	a4,0(a0)
8000011c:	00071463          	bnez	a4,80000124 <print_impl+0x10>
		uart_write(SOC_UART,*msg);
		msg++;
	}
}
80000120:	00008067          	ret
80000124:	0046a783          	lw	a5,4(a3) # 70010004 <_stack_size+0x7000f866>
80000128:	0107d793          	srli	a5,a5,0x10
8000012c:	0ff7f793          	andi	a5,a5,255
static uint32_t uart_readOccupancy(Uart_Reg *reg){
	return reg->STATUS >> 24;
}

static void uart_write(Uart_Reg *reg, uint32_t data){
	while(uart_writeAvailability(reg) == 0);
80000130:	fe078ae3          	beqz	a5,80000124 <print_impl+0x10>
	reg->DATA = data;
80000134:	00e6a023          	sw	a4,0(a3)
		msg++;
80000138:	00150513          	addi	a0,a0,1
8000013c:	fddff06f          	j	80000118 <print_impl+0x4>

Disassembly of section .memory:

80000fd0 <println.part.0>:
      l++;
  }
  print(resptr);
}

static void println(const char*msg){
80000fd0:	ff010113          	addi	sp,sp,-16
80000fd4:	00112623          	sw	ra,12(sp)
static void print(const char*msg){if(!print_enabled) return;print_impl(msg);}
80000fd8:	93cff0ef          	jal	ra,80000114 <print_impl>
  if(!print_enabled) return;
  print(msg);print("\n");
}
80000fdc:	00c12083          	lw	ra,12(sp)
static void print(const char*msg){if(!print_enabled) return;print_impl(msg);}
80000fe0:	80001537          	lui	a0,0x80001
80000fe4:	fa050513          	addi	a0,a0,-96 # 80000fa0 <__global_pointer$+0xfffff7d0>
}
80000fe8:	01010113          	addi	sp,sp,16
static void print(const char*msg){if(!print_enabled) return;print_impl(msg);}
80000fec:	928ff06f          	j	80000114 <print_impl>

80000ff0 <soc_set_gpo>:
#include "print.h"

void soc_set_gpo(uint32_t val){
  Gpio_Reg* soc_gpio = ((Gpio_Reg*)(0x70000000));
  soc_gpio->OUTPUT = val;
80000ff0:	700007b7          	lui	a5,0x70000
80000ff4:	00a7a223          	sw	a0,4(a5) # 70000004 <_stack_size+0x6ffff866>
}
80000ff8:	00008067          	ret

80000ffc <wait_gpo>:

void wait_gpo(Gpio_Reg*gpio, uint32_t mask, uint32_t val){
  while((gpio->OUTPUT & mask) != val);
80000ffc:	00452783          	lw	a5,4(a0)
80001000:	00b7f7b3          	and	a5,a5,a1
80001004:	fec79ce3          	bne	a5,a2,80000ffc <wait_gpo>
}
80001008:	00008067          	ret

8000100c <irqCallback>:
  while(1){
    soc_set_gpo(cnt++);
  }
}

void irqCallback(){
8000100c:	0000006f          	j	8000100c <irqCallback>

Disassembly of section .text.startup:

80001010 <main>:
void main() {
80001010:	ff010113          	addi	sp,sp,-16
80001014:	00112623          	sw	ra,12(sp)
80001018:	00812423          	sw	s0,8(sp)
  while(SOC_GPIO_A->OUTPUT_ENABLE == 0);
8000101c:	70000737          	lui	a4,0x70000
80001020:	00872783          	lw	a5,8(a4) # 70000008 <_stack_size+0x6ffff86a>
80001024:	fe078ee3          	beqz	a5,80001020 <main+0x10>
  while((gpio->OUTPUT & mask) != val);
80001028:	70000437          	lui	s0,0x70000
8000102c:	00442783          	lw	a5,4(s0) # 70000004 <_stack_size+0x6ffff866>
80001030:	0017f793          	andi	a5,a5,1
80001034:	fe078ce3          	beqz	a5,8000102c <main+0x1c>
80001038:	80001537          	lui	a0,0x80001
8000103c:	fa450513          	addi	a0,a0,-92 # 80000fa4 <__global_pointer$+0xfffff7d4>
80001040:	f91ff0ef          	jal	ra,80000fd0 <_bss_end>
  SOC_GPIO_A->OUTPUT=2;
80001044:	00200793          	li	a5,2
80001048:	00f42223          	sw	a5,4(s0)
  while((gpio->OUTPUT & mask) != val);
8000104c:	70000437          	lui	s0,0x70000
80001050:	00442783          	lw	a5,4(s0) # 70000004 <_stack_size+0x6ffff866>
80001054:	0017f793          	andi	a5,a5,1
80001058:	fe078ce3          	beqz	a5,80001050 <main+0x40>
8000105c:	80001537          	lui	a0,0x80001
80001060:	fb850513          	addi	a0,a0,-72 # 80000fb8 <__global_pointer$+0xfffff7e8>
80001064:	f6dff0ef          	jal	ra,80000fd0 <_bss_end>
  SOC_GPIO_A->OUTPUT=4;
80001068:	00400793          	li	a5,4
8000106c:	00f42223          	sw	a5,4(s0)
80001070:	0000006f          	j	80001070 <main+0x60>
