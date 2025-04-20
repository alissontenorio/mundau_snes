require_relative 'memory/mapper'
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

        # ToDo: Maybe remove SRAM from here, since its from cartridge
        SRAM = Array.new(32768, 0) # 32 KB # Max access up to 32767 (0x7FFF)
        RAM = Array.new(131072, 0) # 128 KB # Max access up to 131071 (0x1FFFF)

        attr_accessor :m_map

        def initialize(debug = false)
            @cartridge = nil
            @m_map = nil
            @debug = debug
        end

        def insert_cartridge(filepath)
            rom_raw = open_rom(filepath)
            @cartridge = Rom::CartridgeBuilder.new(rom_raw).get_cartridge
            @m_map = Snes::Memory::Mapper.new(@cartridge, RAM, SRAM, @debug)
        end

        def print_cartridge_header
            # ToDo: Check if Cartridge is inserted
            @cartridge.print
            puts "#{@cartridge.cartridge_type}"
        end

        def current_memory_mapper
            @m_map
        end

        def turn_on
            # ToDo: Check if Cartridge is inserted

            # Access CPU / DMA
            # Access PPU
            # Access Controller
        end

        def turn_off
            @cartridge = nil
            @m_map = nil
        end

        def remove_cartridge
            @cartridge = nil
            @m_map = nil
        end
    end
end