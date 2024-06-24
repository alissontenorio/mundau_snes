require_relative 'memory/snes_memory_map'
require_relative 'cpu/ricoh_5a22'
require_relative '../cartridge/cartridge'
require_relative '../cartridge/cartridge_builder'
require_relative '../utils/file'

module Snes
    class Console
        include Utils::FileOperations

        LOW_CLOCK_SPEED = 1.79    # 12-clocks per cycle
        MEDIUM_CLOCK_SPEED = 2.68 # 8-clocks per cycle) (200ns)
        HIGH_CLOCK_SPEED = 3.58   # 6-clocks per cycle) (120ns)

        CPU = Snes::CPU::Ricoh_5A22.instance

        def initialize(debug = false)
            @cartridge = nil
            @m_map = nil
            @debug = debug
        end

        def insert_cartridge(filepath)
            rom_raw = open_rom(filepath)
            @cartridge = Rom::CartridgeBuilder.new(rom_raw).get_cartridge
            if @debug
                @cartridge.print
                puts "#{@cartridge.cartridge_type}"
            end
        end

        def set_memory_mapper
            @m_map = Snes::Memory::MemoryMap.new(@cartridge)
        end

        def turn_on
            set_memory_mapper

            # LoROM

            # Access SRAM
            @m_map.read(0x701FC0)
            @m_map.read(0x701FC0)
            @m_map.read(0x702FC0)
            @m_map.read(0x705FC0)
            @m_map.read(0x707FFF)
            @m_map.read(0x7D1FC0)
            @m_map.read(0x7D2FC0)
            @m_map.read(0x7D5FC0)
            @m_map.read(0x7D7FFF)

            # Access CPU / DMA
            # Access PPU
            # Access Controller
        end
    end
end