package vexriscv.ip

import spinal.core._
import spinal.lib._
import spinal.lib.io.TriStateArray
import spinal.lib.bus.amba3.apb.{Apb3, Apb3Config, Apb3SlaveFactory, Apb3Decoder}
import spinal.lib.bus.amba3.ahblite._
import spinal.lib.bus.amba4.axi._
import spinal.lib.bus.misc.{SizeMapping,BusSlaveFactory}
import spinal.lib.bus.simple.PipelinedMemoryBus
import spinal.lib.com.jtag.{Jtag,JtagTap}
import spinal.lib.misc.{HexTools, InterruptCtrl, Prescaler, Timer}
import spinal.lib.com.spi.ddr._
import spinal.lib.bus.simple._
import vexriscv.{VexRiscv, VexRiscvConfig, plugin}
import scala.collection.mutable.ArrayBuffer
import vexriscv.plugin._

object MasterSubsys{
  def getAhbConfig() = AhbLite3Config(addressWidth = 31,dataWidth = 32)
  def getAxiConfig() = Axi4Config(
    addressWidth = 32,
    dataWidth    = 32,
    useId = false,
    useRegion = false,
    useBurst = false,
    useLock = false,
    useQos = false,
    useLen = false,
    useResp = true
  )
}

case class MasterSubsys(config : SubsysModelSysConfig = SubsysModelSysConfig.default()) extends Component {
    import config._

    val clk = in Bool
    val rstb = in Bool
    val io = new Bundle {
        val jtag = slave(Jtag())
        //val ahb  = master(AhbLite3Master(AhbSubsys.getAhbConfig()))
        val axi = master(Axi4Shared(MasterSubsys.getAxiConfig()))
    }
    val systemReset = Bool
    val mainClockDomain = ClockDomain(
        clock = clk,
        reset = systemReset,
        config = ClockDomainConfig(
          clockEdge        = RISING,
          resetKind        = spinal.core.ASYNC,
          resetActiveLevel = HIGH
        )
    )
    val debugClockDomain = ClockDomain(
      clock = clk,
      reset = systemReset,
      config = ClockDomainConfig(
        clockEdge        = RISING,
        resetKind        = spinal.core.ASYNC,
        resetActiveLevel = HIGH
      )
    )
    val mainClockArea = new ClockingArea(mainClockDomain){

        val system = new Area() {
            val pipelinedMemoryBusConfig = PipelinedMemoryBusConfig(
              addressWidth = 32,
              dataWidth = 32
            )

            //Arbiter of the cpu dBus/iBus to drive the mainBus
            //Priority to dBus, !! cmd transactions can change on the fly !!
            val mainBusArbiter = new SubsysModelMasterArbiter(pipelinedMemoryBusConfig)

            //Instanciate the CPU
            val cpu = new VexRiscv(
              config = VexRiscvConfig(
                plugins = cpuPlugins += new DebugPlugin(debugClockDomain, hardwareBreakpointCount)
                //plugins = cpuPlugins
              )
            )

            //Checkout plugins used to instanciate the CPU to connect them to the SoC
            val timerInterrupt = False
            val jtagInterrupt = False
            //val externalInterrupt = False
            systemReset := False
            for(plugin <- cpu.plugins) plugin match{
              case plugin : vexriscv.plugin.IBusSimplePlugin =>
                mainBusArbiter.io.iBus.cmd <> plugin.iBus.cmd
                mainBusArbiter.io.iBus.rsp <> plugin.iBus.rsp
              case plugin : vexriscv.plugin.DBusSimplePlugin => {
                if(!pipelineDBus)
                  mainBusArbiter.io.dBus <> plugin.dBus
                else {
                  mainBusArbiter.io.dBus.cmd << plugin.dBus.cmd.halfPipe()
                  mainBusArbiter.io.dBus.rsp <> plugin.dBus.rsp
                }
              }
              case plugin : vexriscv.plugin.CsrPlugin        => {
                plugin.externalInterrupt := jtagInterrupt
                plugin.timerInterrupt := timerInterrupt
              }
              case plugin : DebugPlugin         => plugin.debugClockDomain{
                systemReset setWhen(RegNext(plugin.io.resetOut))
                io.jtag <> plugin.io.bus.fromJtag()
              }
              case _ =>
            }

            //****** MainBus slaves ********
            val mainBusMapping = ArrayBuffer[(PipelinedMemoryBus,SizeMapping)]()
            val masterBridge = new PipelinedMemoryBusToAxi4SharedBridge(
              axiConfig = Axi4Config(
                addressWidth = 32,
                dataWidth    = 32,
                useId = false,
                useRegion = false,
                useBurst = false,
                useLock = false,
                useQos = false,
                useLen = false,
                useResp = true
              ),
              pipelineBridge = false,
              pipelinedMemoryBusConfig = pipelinedMemoryBusConfig
            )
            masterBridge.io.axi <> io.axi
            mainBusMapping += masterBridge.io.pipelinedMemoryBus -> (0x00000000l, 2 GB)

            val ram = new SubsysModelPipelinedMemoryBusRam(
              onChipRamSize = onChipRamSize,
              onChipRamHexFile = onChipRamHexFile,
              pipelinedMemoryBusConfig = pipelinedMemoryBusConfig
            )
            mainBusMapping += ram.io.bus -> (0x80000000l, onChipRamSize)

            val apbBridge = new PipelinedMemoryBusToApbBridge(
              apb3Config = Apb3Config(
                addressWidth = 20,
                dataWidth = 32
              ),
              pipelineBridge = pipelineApbBridge,
              pipelinedMemoryBusConfig = pipelinedMemoryBusConfig
            )
            mainBusMapping += apbBridge.io.pipelinedMemoryBus -> (0xF0000000l, 1 MB)


            //******** APB peripherals *********
            val apbMapping = ArrayBuffer[(Apb3, SizeMapping)]()

            val timer = new SubsysModelApb3Timer()
            timerInterrupt setWhen(timer.io.interrupt)
            apbMapping += timer.io.apb     -> (0x20000, 4 kB)

            //val jtag = new SubsysModelApb3Jtag()
            //jtagInterrupt setWhen(jtag.io.interrupt)
            //apbMapping += jtag.io.apb     -> (0x50000, 4 kB)
            //io.jtag <> jtag.io.jtag
            //jtag.io.reset := !PRESETn

            //******** Memory mappings *********
            val apbDecoder = Apb3Decoder(
              master = apbBridge.io.apb,
              slaves = apbMapping
            )

            val mainBusDecoder = new Area {
              val logic = new SubsysModelPipelinedMemoryBusDecoder(
                master = mainBusArbiter.io.masterBus,
                specification = mainBusMapping,
                pipelineMaster = pipelineMainBus
              )
            }
        }
    }
}

object Subsys{
  def main(args: Array[String]) {
    SpinalVerilog{
        val c = MasterSubsys()
        //port renaming may take place here
        c
    }
  }
}
