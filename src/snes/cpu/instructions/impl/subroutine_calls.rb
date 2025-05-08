module Snes::CPU::Instructions::SubroutineCalls
    # JSR
    def jsr_abs
        target = fetch_data

        return_address = (@pc - 1) & 0xFFFF
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
