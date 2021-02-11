package vexriscv.ip

//import vexriscv.demo.JtagTap8
import spinal.core._
import spinal.lib._
import spinal.lib.io.TriStateArray
import spinal.lib.bus.amba3.apb.{Apb3, Apb3Config, Apb3SlaveFactory, Apb3Decoder}
import spinal.lib.bus.amba3.ahblite._
import spinal.lib.bus.amba4.axi._
import spinal.lib.bus.misc.{SizeMapping,BusSlaveFactory}
import spinal.lib.bus.simple.PipelinedMemoryBus
import spinal.lib.com.jtag.{Jtag,JtagTap,JtagTapAccess,JtagInstruction,JtagState}
import spinal.lib.misc.{HexTools, InterruptCtrl, Prescaler, Timer}
import spinal.lib.com.spi.ddr._
import spinal.lib.bus.simple._

//import vexriscv.plugin._
import vexriscv.{VexRiscv, VexRiscvConfig, plugin}
import scala.collection.mutable.ArrayBuffer


case class SubsysModelSysConfig(coreFrequency : HertzNumber,
                       onChipRamSize      : BigInt,
                       onChipRamHexFile   : String,
                       pipelineDBus       : Boolean,
                       pipelineMainBus    : Boolean,
                       pipelineApbBridge  : Boolean,
                       hardwareBreakpointCount : Int,
                       cpuPlugins         : ArrayBuffer[vexriscv.plugin.Plugin[VexRiscv]]){
  require(pipelineApbBridge || pipelineMainBus, "At least pipelineMainBus or pipelineApbBridge should be enable to avoid wipe transactions")

}



object SubsysModelSysConfig{
  import vexriscv.plugin._
  def default() =  SubsysModelSysConfig(
    coreFrequency         = 12 MHz,
    onChipRamSize         = 32 kB,
    onChipRamHexFile      = "software/subsys/build/subsys.hex",
    pipelineDBus          = true,
    pipelineMainBus       = false,
    pipelineApbBridge     = true,
    hardwareBreakpointCount = 0,
    cpuPlugins = ArrayBuffer( //DebugPlugin added by the toplevel
      new vexriscv.plugin.IBusSimplePlugin(
        resetVector = 0x80000000l,
        cmdForkOnSecondStage = true,
        cmdForkPersistence = false,
        prediction = vexriscv.plugin.NONE,
        catchAccessFault = false,
        compressedGen = true
      ),
      new vexriscv.plugin.DBusSimplePlugin(
        catchAddressMisaligned = false,
        catchAccessFault = false,
        earlyInjection = false
      ),
      new vexriscv.plugin.CsrPlugin(vexriscv.plugin.CsrPluginConfig.smallest(mtvecInit = 0x80000020l)),
      new vexriscv.plugin.DecoderSimplePlugin(
        catchIllegalInstruction = false
      ),
      new vexriscv.plugin.RegFilePlugin(
        regFileReadyKind = plugin.SYNC,
        zeroBoot = false
      ),
      new vexriscv.plugin.IntAluPlugin,
      new MulPlugin,
      new DivPlugin,
      new vexriscv.plugin.SrcPlugin(
        separatedAddSub = false,
        executeInsertion = false
      ),
      new FullBarrelShifterPlugin(earlyInjection=false),
      //new vexriscv.plugin.LightShifterPlugin,
      new vexriscv.plugin.HazardSimplePlugin(
        bypassExecute = false,
        bypassMemory = false,
        bypassWriteBack = false,
        bypassWriteBackBuffer = false,
        pessimisticUseSrc = false,
        pessimisticWriteRegFile = false,
        pessimisticAddressMatch = false
      ),
      new vexriscv.plugin.BranchPlugin(
        earlyBranch = false,
        catchAddressMisaligned = false
      ),
      new vexriscv.plugin.YamlPlugin("subsys.cpu0.yaml")
    )
  )
}




class SubsysModelMasterArbiter(pipelinedMemoryBusConfig : PipelinedMemoryBusConfig) extends Component{
  import vexriscv.plugin._
  val io = new Bundle{
    val iBus = slave(IBusSimpleBus(null))
    val dBus = slave(DBusSimpleBus())
    val masterBus = master(PipelinedMemoryBus(pipelinedMemoryBusConfig))
  }

  io.masterBus.cmd.valid   := io.iBus.cmd.valid || io.dBus.cmd.valid
  io.masterBus.cmd.write      := io.dBus.cmd.valid && io.dBus.cmd.wr
  io.masterBus.cmd.address := io.dBus.cmd.valid ? io.dBus.cmd.address | io.iBus.cmd.pc
  io.masterBus.cmd.data    := io.dBus.cmd.data
  io.masterBus.cmd.mask    := io.dBus.cmd.size.mux(
    0 -> B"0001",
    1 -> B"0011",
    default -> B"1111"
  ) |<< io.dBus.cmd.address(1 downto 0)
  io.iBus.cmd.ready := io.masterBus.cmd.ready && !io.dBus.cmd.valid
  io.dBus.cmd.ready := io.masterBus.cmd.ready


  val rspPending = RegInit(False) clearWhen(io.masterBus.rsp.valid)
  val rspTarget = RegInit(False)
  when(io.masterBus.cmd.fire && !io.masterBus.cmd.write){
    rspTarget  := io.dBus.cmd.valid
    rspPending := True
  }

  when(rspPending && !io.masterBus.rsp.valid){
    io.iBus.cmd.ready := False
    io.dBus.cmd.ready := False
    io.masterBus.cmd.valid := False
  }

  io.iBus.rsp.valid := io.masterBus.rsp.valid && !rspTarget
  io.iBus.rsp.inst  := io.masterBus.rsp.data
  io.iBus.rsp.error := False

  io.dBus.rsp.ready := io.masterBus.rsp.valid && rspTarget
  io.dBus.rsp.data  := io.masterBus.rsp.data
  io.dBus.rsp.error := False
}


case class SubsysModelPipelinedMemoryBusRam(onChipRamSize : BigInt, onChipRamHexFile : String, pipelinedMemoryBusConfig : PipelinedMemoryBusConfig) extends Component{
  val io = new Bundle{
    val bus = slave(PipelinedMemoryBus(pipelinedMemoryBusConfig))
  }

  val ram = Mem(Bits(32 bits), onChipRamSize / 4)
  io.bus.rsp.valid := RegNext(io.bus.cmd.fire && !io.bus.cmd.write) init(False)
  io.bus.rsp.data := ram.readWriteSync(
    address = (io.bus.cmd.address >> 2).resized,
    data  = io.bus.cmd.data,
    enable  = io.bus.cmd.valid,
    write  = io.bus.cmd.write,
    mask  = io.bus.cmd.mask
  )
  io.bus.cmd.ready := True

  if(onChipRamHexFile != null){
    HexTools.initRam(ram, onChipRamHexFile, 0x80000000l)
  }
}

case class PipelinedMemoryBusToAxi4SharedBridge(axiConfig: Axi4Config, pipelineBridge : Boolean, pipelinedMemoryBusConfig : PipelinedMemoryBusConfig) extends Component{
  assert(axiConfig.dataWidth == pipelinedMemoryBusConfig.dataWidth)

  val io = new Bundle {
    val pipelinedMemoryBus = slave(PipelinedMemoryBus(pipelinedMemoryBusConfig))
    val axi = master(Axi4Shared(axiConfig))
  }

  val busStage = PipelinedMemoryBus(pipelinedMemoryBusConfig)
  busStage.cmd << (if(pipelineBridge) io.pipelinedMemoryBus.cmd.halfPipe() else io.pipelinedMemoryBus.cmd)
  busStage.rsp >-> io.pipelinedMemoryBus.rsp

  //taken from DbusSimplePlugin
  val pendingWritesMax : Int = 7
  val cmdPreFork = busStage.cmd

  val pendingWrites = CounterUpDown(
    stateCount = pendingWritesMax + 1,
    incWhen = cmdPreFork.fire && cmdPreFork.write,
    decWhen = io.axi.writeRsp.fire
  )

  val hazard = (pendingWrites =/= 0 && cmdPreFork.valid && !cmdPreFork.write) || pendingWrites === pendingWritesMax
  val (cmdFork, dataFork) = StreamFork2(cmdPreFork.haltWhen(hazard))
  val cmdForkSize = CountOne(cmdFork.mask)-1
  io.axi.sharedCmd.arbitrationFrom(cmdFork)
  io.axi.sharedCmd.write := cmdFork.write
  io.axi.sharedCmd.prot := "010"
  io.axi.sharedCmd.cache := "1111"
  io.axi.sharedCmd.size := cmdForkSize.resized
  io.axi.sharedCmd.addr := U"h80000000" | cmdFork.address.resized

  val dataStage = dataFork.throwWhen(!dataFork.write)
  io.axi.writeData.arbitrationFrom(dataStage)
  io.axi.writeData.last := True
  io.axi.writeData.data := dataStage.data
  io.axi.writeData.strb := dataStage.mask

  busStage.rsp.valid := io.axi.r.valid
  //busStage.rsp.error := !io.axi.r.isOKAY()
  busStage.rsp.data := io.axi.r.data

  io.axi.r.ready := True
  io.axi.b.ready := True
}
/*
case class PipelinedMemoryBusToAhbBridge(ahbConfig: AhbLite3Config, pipelineBridge : Boolean, pipelinedMemoryBusConfig : PipelinedMemoryBusConfig) extends Component{
  assert(ahbConfig.dataWidth == pipelinedMemoryBusConfig.dataWidth)

  val io = new Bundle {
    val pipelinedMemoryBus = slave(PipelinedMemoryBus(pipelinedMemoryBusConfig))
    val ahb = master(AhbLite3Master(ahbConfig))
  }

  val busStage = PipelinedMemoryBus(pipelinedMemoryBusConfig)
  busStage.cmd << (if(pipelineBridge) io.pipelinedMemoryBus.cmd.halfPipe() else io.pipelinedMemoryBus.cmd)
  busStage.rsp >-> io.pipelinedMemoryBus.rsp

  busStage.cmd.ready := io.ahb.HREADY

  when(busStage.cmd.valid) {
    io.ahb.HTRANS  := AhbLite3.NONSEQ //NONSEQ
  } otherwise {
    io.ahb.HTRANS  := AhbLite3.IDLE //IDLE
  }
  io.ahb.HBURST    := 0 // SINGLE
  io.ahb.HSIZE     := B(busStage.cmd.size, 3 bits)
  io.ahb.HPROT     := "1111"
  io.ahb.HMASTLOCK := False
  io.ahb.HWRITE    := busStage.cmd.write
  io.ahb.HADDR     := busStage.cmd.address.resized
  io.ahb.HWDATA    := RegNextWhen(busStage.cmd.data, bus.HREADY)

  val pending = RegInit(False) clearWhen(bus.HREADY) setWhen(busStage.cmd.fire && !busStage.cmd.write)
  busStage.rsp.ready := io.ahb.HREADY && pending
  busStage.rsp.data  := io.ahb.HRDATA
  busStage.rsp.error := io.ahb.HRESP
}*/


class SubsysModelPipelinedMemoryBusDecoder(master : PipelinedMemoryBus, val specification : Seq[(PipelinedMemoryBus,SizeMapping)], pipelineMaster : Boolean) extends Area{
  val masterPipelined = PipelinedMemoryBus(master.config)
  if(!pipelineMaster) {
    masterPipelined.cmd << master.cmd
    masterPipelined.rsp >> master.rsp
  } else {
    masterPipelined.cmd <-< master.cmd
    masterPipelined.rsp >> master.rsp
  }

  val slaveBuses = specification.map(_._1)
  val memorySpaces = specification.map(_._2)

  val hits = for((slaveBus, memorySpace) <- specification) yield {
    val hit = memorySpace.hit(masterPipelined.cmd.address)
    slaveBus.cmd.valid   := masterPipelined.cmd.valid && hit
    slaveBus.cmd.payload := masterPipelined.cmd.payload.resized
    hit
  }
  val noHit = !hits.orR
  masterPipelined.cmd.ready := (hits,slaveBuses).zipped.map(_ && _.cmd.ready).orR || noHit

  val rspPending  = RegInit(False) clearWhen(masterPipelined.rsp.valid) setWhen(masterPipelined.cmd.fire && !masterPipelined.cmd.write)
  val rspNoHit    = RegNext(False) init(False) setWhen(noHit)
  val rspSourceId = RegNextWhen(OHToUInt(hits), masterPipelined.cmd.fire)
  masterPipelined.rsp.valid   := slaveBuses.map(_.rsp.valid).orR || (rspPending && rspNoHit)
  masterPipelined.rsp.payload := slaveBuses.map(_.rsp.payload).read(rspSourceId)

  when(rspPending && !masterPipelined.rsp.valid) { //Only one pending read request is allowed
    masterPipelined.cmd.ready := False
    slaveBuses.foreach(_.cmd.valid := False)
  }
}

class SubsysModelApb3Timer extends Component{
  val io = new Bundle {
    val apb = slave(Apb3(
      addressWidth = 8,
      dataWidth = 32
    ))
    val interrupt = out Bool
  }

  val prescaler = Prescaler(20)
  val timerA,timerB = Timer(20)

  val busCtrl = Apb3SlaveFactory(io.apb)
  val prescalerBridge = prescaler.driveFrom(busCtrl,0x00)

  val timerABridge = timerA.driveFrom(busCtrl,0x40)(
    ticks  = List(True, prescaler.io.overflow),
    clears = List(timerA.io.full)
  )

  val timerBBridge = timerB.driveFrom(busCtrl,0x50)(
    ticks  = List(True, prescaler.io.overflow),
    clears = List(timerB.io.full)
  )

  val interruptCtrl = InterruptCtrl(2)
  val interruptCtrlBridge = interruptCtrl.driveFrom(busCtrl,0x10)
  interruptCtrl.io.inputs(0) := timerA.io.full
  interruptCtrl.io.inputs(1) := timerB.io.full
  io.interrupt := interruptCtrl.io.pendings.orR
}
