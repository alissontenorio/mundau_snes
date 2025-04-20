require 'logger'

module Snes
    module Memory
        class HiRomMapper < Mapper
            def read_rom(bank, offset)
                raise NotImplementedError, "#{__method__} must be implemented in a subclass"
            end

            def read_sram(bank, offset)
                $logger.debug("#{__method__}") if @debug
                sram_pos = position_in_contiguous_memory(bank, offset, 0x30, 0x6000, 0x2000)
                @sram[sram_pos]
            end
        end
    end
end
