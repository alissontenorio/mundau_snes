require_relative 'memory/mapper'
require_relative 'cpu/ricoh_5a22'


module Snes
    class Console
        # include Utils::FileOperations

        LOW_CLOCK_SPEED = 1.79    # 12-clocks per cycle
        MEDIUM_CLOCK_SPEED = 2.68 # 8-clocks per cycle) (200ns)
        HIGH_CLOCK_SPEED = 3.58   # 6-clocks per cycle) (120ns)

        Ricoh_CPU = Snes::CPU::Ricoh_5A22.instance
        WDC_CORE = Snes::CPU::WDC65816.instance
        InternalCPU_Registers = Snes::CPU::InternalCPURegisters.instance

        # ToDo: Maybe remove SRAM from here, since its from cartridge
        SRAM = Array.new(32768, 0) # 32 KB # Max access up to 32767 (0x7FFF)
        RAM = Array.new(131072, 0) # 128 KB # Max access up to 131071 (0x1FFFF)

        attr_accessor :m_map, :cartridge

        def initialize(debug = false)
            @cartridge = nil
            @m_map = nil
            @debug = debug
        end

        def insert_cartridge(cartridge)
            @cartridge = cartridge
            @m_map = Snes::Memory::Mapper.new(@cartridge, RAM, SRAM, InternalCPU_Registers, @debug)
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
            raise "Cartridge not inserted error" unless @cartridge

            WDC_CORE.setup(@m_map, @cartridge.emulation_vectors[:reset], @debug)

            # Access CPU / DMA
            # Access PPU
            # Access Controller
            test_counter = 0
            while true
                puts WDC_CORE.inspect
                $logger.debug("#{WDC_CORE.inspect}") if @debug
                WDC_CORE.fetch_decode_execute
                $stdout.flush
                sleep(1)
                return if test_counter > 4
            end
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