# Software on Vexrisc

## To generate Corenc.v
`sbt "runMain vexriscv.demo.Corenc"`

## Verilator Sim

to generate trace (vcd file):
`make clean run TRACE=yes`

## to build with vivado
`source /home/user/bin/Xilinx/Vivado/2018.2/settings64.sh`
then `./build_arty`

## Debugger tab in eclipse

### GDB Setup
GDB command:
`/opt/riscv/bin/riscv64-unknown-elf-gdb`

### Remote Target
- [x] use remote target
- JTAG device: OpenOCD via socket
- Host name: localhost
- Port number 3333

## Startup tab in eclipse

### Initialization command
`set arch riscv:rv32`

### Load image and Symbols
- [x] load image
- [x] use project binary
- [x] load symbols
- [x] use project binary]

## Open OCD:
````
user@lafite:~/Downloads/openocd_riscv$ src/openocd -f tcl/interface/jtag_tcp.cfg -c "set BRIEY_CPU0_YAML /home/user/Downloads/VexRisc_fork/cpu0.yaml" -f tcl/target/briey.cfg
````

briey.cfg:
````
set  _ENDIAN little
set _TAP_TYPE 1234

if { [info exists CPUTAPID] } {
   set _CPUTAPID $CPUTAPID
} else {
  # set useful default
   set _CPUTAPID 0x10001fff
}

adapter_khz 4000
adapter_nsrst_delay 260
jtag_ntrst_delay 250

set _CHIPNAME fpga_spinal
jtag newtap $_CHIPNAME bridge -expected-id $_CPUTAPID -irlen 4 -ircapture 0x1 -irmask 0xF

target create $_CHIPNAME.cpu0 vexriscv -endian $_ENDIAN -chain-position $_CHIPNAME.bridge -coreid 0 -dbgbase 0xF00F0000
vexriscv readWaitCycles 12
vexriscv cpuConfigFile $BRIEY_CPU0_YAML

poll_period 50

init
#echo "Halting processor"
soft_reset_halt
````


## Start a debug session

### Verilator
- start verilator
- start openOCD
- start debug session in eclipse
- wait for it tp stabilize
- press "instruction level debug"
- wait for it to stabilize
- press "step"
- now it works as usual :-)

if it does not, check JTAG frequency in main.cpp, shall be 4 times the main clock.
