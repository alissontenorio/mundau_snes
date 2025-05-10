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
    def brk # 0x00 - Force Interrupt (Software Interrupt)
        @cycles += 7 # Base BRK timing. You may adjust this later depending on accurate timing modeling

        # The return address is PC + 2 even though BRK is a 1-byte instruction
        # because the byte after BRK is treated as a "signature" byte (ignored by CPU)
        return_address = (@pc + 2) & 0xFFFF

        if @emulation_mode
            # Emulation mode: 8-bit stack and no PBR push
            push_8((return_address >> 8) & 0xFF)
            push_8(return_address & 0xFF)
            push_8(@p | 0x10)  # Push status with B (break) flag set

            set_p_flag(:i, true) # Set interrupt disable
            @pc = read_word(@emulation_vectors[:irq_brk])
        else
            # Native mode: 16-bit stack, push PBR, full return address
            push_8(@pbr)                           # Push Program Bank
            push_8((return_address >> 8) & 0xFF)   # Push PC high byte
            push_8(return_address & 0xFF)          # Push PC low byte
            push_8(@p)                             # Status register (B not set in native)

            set_p_flag(:i, true)     # Set interrupt disable
            set_p_flag(:d, false)    # Clear decimal flag per 65C816 behavior
            @pbr = 0                 # Jumping to bank 0 for interrupt vector

            @pc = read_word(@native_vectors[:brk])
            @cycles += 1 # Additional cycle in native mode
        end
    end


    # RTI
end
