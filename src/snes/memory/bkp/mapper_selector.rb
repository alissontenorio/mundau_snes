require_relative '../../../exceptions'
require_relative 'bkp/hirom_memory_mapper'
require_relative 'lorom_memory_mapper'


# ToDo: Segmentation Fault
#
# This console also features a special ‘anomaly’ called Open Bus:
# If there is an instruction trying to read from an unmapped/invalid address,
# the last value read is supplied instead (the CPU stores this value in a register
# called Memory Data Register or MDR) and execution carries on in an unpredictable state.
#
# For comparison, the 68000 uses a vector table to handle exceptions, so execution will
# be redirected whenever a fault is detected.

module Snes
    module Memory
        class MapperSelector
            # 960KB is the maximum a SRAM can have, most games use 8KB, I'll just put 32 KB
            SRAM = Array.new(32768, 0) # 32 KB # Max access up to 32767 (0x7FFF)
            RAM = Array.new(131072, 0) # 128 KB # Max access up to 131071 (0x1FFFF)

            def initialize(cartridge)
                @cartridge = cartridge
                @mapper = select_mapper
            end

            def select_mapper
                case @cartridge.cartridge_type
                when "LoROM"
                    LoRomMemoryMapper.new(@cartridge, RAM, SRAM)
                when "HiROM"
                    HiRomMemoryMapper.new(@cartridge, RAM, SRAM)
                when "ExHiROM"
                    # ExHiRomMemoryMapper.new(cartridge)
                    raise NoMethodError.new("Cartridge type not implemented")
                else
                    raise NoMethodError.new("Cartridge type not implemented")
                end
            end
        end
    end
end
