module Snes
    module CPU
        module Instructions
            module SubroutineCalls
                def push_8(value)
                    if @emulation_mode
                        address = 0x0100 | (@sp & 0xFF)
                        @memory.access(address, :write, value & 0xFF)
                        @sp = (@sp - 1) & 0xFF
                    else
                        address = (@stack_bank << 16) | @sp
                        @memory.access(address, :write, value & 0xFF)
                        @sp = (@sp - 1) & 0xFFFF
                    end
                end



                # JSR
                def jsr_abs
                    target = fetch_data

                    return_address = (full_pc - 1) & 0xFFFF
                    push_8((return_address >> 8) & 0xFF) # high byte
                    push_8(return_address & 0xFF)        # low byte

                    @pc = target
                end

                # RTS
                # JSL
                # RTL
                # PEA
                # COP
                # BRK
                # RTI
            end
        end
    end
end
