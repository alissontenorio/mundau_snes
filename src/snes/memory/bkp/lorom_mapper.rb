require 'logger'

module Snes
    module Memory
        class LoRomMapper < Mapper
            def memory_access_rom(bank, offset)
                raise NotImplementedError, "#{__method__} must be implemented in a subclass"
            end

            def memory_access_sram(bank, offset)
                $logger.debug("#{__method__}") if @debug
                sram_pos = position_in_contiguous_memory(bank, offset, 0x70, 0x0, 0x8000)
                @sram[sram_pos]
            end
        end
    end
end
