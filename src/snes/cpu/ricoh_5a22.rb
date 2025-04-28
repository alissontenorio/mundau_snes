# require_relative '../bus/bus_a'
# require_relative '../bus/bus'
# require_relative 'wdc_65816'
# require_relative 'dma/gpdma'
# require_relative 'dma/hdma'
# require 'singleton'
#
# module Snes
#     module CPU
#         # Core - Ricoh 5A22 - Based on 6502 CPU - WDC 65C816
#         class Ricoh_5A22
#             include Singleton
#
#             # # Singleton stuff
#             # @instance = new
#             # private_class_method :new
#             # def self.instance; @instance end
#
#             # 65816 assembly
#             # Clock Speed - The device speed (ROM, RAM, LSI, etc) will determine the speed to be used
#             # 3.58 MHz during register operations - non-access cycles
#             # 2.68 MHz
#             # 1.79 MHz when accessing the slowest buses (i.e. the serial/controller port)
#             #
#             # If a medium speed ROM and RAM (access time less than 200ns) are used in the cartridge, it will be mapped
#             # to the address area for 2.68 MHz.
#             #
#             # If a high speed (access time less than 120ns) are used, it will be mapped for 3.58MHZ
#             #
#             # Refer to "Frequency & Address Mapping" for the relation between the address and the clock
#             #
#             # Two clocks (2.68 MHz and 3.58 MHz) can be selected by setting D0 of register <420DH> for the range of memory (2)
#             # (illustration in book 1 snes dev page 2-21-2)
#             #
#
#             BUS_A = Snes::Bus::BusA.instance # 24-bit general access
#             BUS_B = Snes::Bus::Bus.instance # 8-bit mostly to register of APU and PPU
#
#             # 8-channel DMA unit
#
#             # Porta de interface para os circuitos do controlador, incluindo ambos acessos serial e paralelo aos dados do controlador
#             # Uma porta I/O paralela de 8-bit, que quase não é usada no SNES
#             # Circuitos para geração de Interrupção NMI ou V-Blank.
#             # Circuitos para geração de Interrupção IRQ ao calcular as posições da tela
#             # Uma unidade DMA, suportando dois modos primários:
#             # DMA geral, para uma transferência de blocos à uma taxa de 2.68MB/s
#             # DMA H-blank, para transferência de pequenos conjuntos de dados no final de cada linha de scan fora do período ativo de exibição.
#             # Multiplicação e divisão de registros
#             WDC_65816 = Snes::CPU::WDC65816.instance
#
#             GPDMA = Snes::CPU::DMA::GPDMA.instance
#             HDMA = Snes::CPU::DMA::HDMA.instance
#
#             @@controllers = 0
#
#             def self.total
#                 @@controllers
#             end
#         end
#     end
# end