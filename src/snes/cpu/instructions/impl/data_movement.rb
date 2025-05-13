module Snes::CPU::Instructions::DataMovement
    # Load/Store Instructions

    # LDX
    # LDY

    def ldy_imm
        value = fetch_data(p_flag: :x)

        if status_p_flag?(:x) # 8-bit index register (X/Y)
            @y = value & 0x00FF # ToDo: Check if this is correct, Maybe we need to preserve the high byte of Y
            # @y = (@y & 0xFF00) | value
            set_nz_flags(@y, true)
        else # 16-bit index register
            @y = value & 0xFFFF
            set_nz_flags(@y, false)
            @cycles += 1
        end
    end

    # STX
    # STY

    # LDA
    def lda
        value = fetch_data

        if status_p_flag?(:m) # 8-bit - emulation
            @a = (@a & 0xFF00) | value # Store value into the low byte of A, keeping high byte intact
            set_nz_flags(@a & 0xFF, true)
        else # 16-bit - native
            @a = value & 0xFFFF
            set_nz_flags(@a, false)
            @cycles += 1
        end
    end

    def lda_imm # 0xA9
        lda
    end

    def lda_dp_indirect_long_y # 0xB7
        lda
    end

    # STA
    def sta # abs
        address = fetch_data

        if status_p_flag?(:m) # 8-bit accumulator mode
            value = @a & 0x00FF  # Use only the low 8 bits of A
            write_byte(address, value)
        else # 16-bit accumulator mode
            value = @a & 0xFFFF  # Use full 16 bits of A
            write_word(address, value)

            @cycles += 1
        end
    end

    def sta_abs # 0x8D
        sta
    end

    def sta_dp
        sta
    end

    # STZ
    # Store Zero to Memory
    def stz_abs # 0x9C
        address = fetch_data

        if status_p_flag?(:m)
            write_byte(address, 0x00) # emulation mode
        else
            write_word(address, 0x0000) # native mode
            @cycles += 1
        end
    end

    # def stz_dp
    #     offset = read_8           # Fetch 8-bit offset
    #     address = address_direct_page(offset)    # Compute effective 24-bit address
    #
    #     if status_p_flag?(:m)
    #         write_8(address, 0x00) # emulation mode
    #     else
    #         write_16(address, 0x0000) # native mode
    #         @cycles += 1 # Add 1 cycle if M flag is 0 (16-bit mode)
    #     end
    #
    #     @cycles += 1 if (@dp & 0x00FF) != 0x00   # Add 1 if DP low byte is not zero
    #
    #     @cycles += (@dp == 0 ? 3 : 4)
    # end

    # Push Instructions
    # PHA
    def pha # 0x48
        if status_p_flag?(:m)
            push_byte(@a & 0xFF)
        else
            push_byte(@a & 0xFFFF)
        end
    end

    # PHP
    def php
        push_byte(@p)
    end

    # PHX
    # PHY
    # PHB
    # PHK
    # PHD

    # Push Instructions Introduced
    # PEA
    # PEI
    # PER

    # Pull Instructions
    # PLA
    def pla # 0x68
        if status_p_flag?(:m)
            value = pull_byte
            @a = (@a & 0xFF00) | value
            set_nz_flags(value, true)
        else
            value = pull_word
            @a = value
            set_nz_flags(value, false)

            @cycles += 1
        end
    end

    # PLP
    # PLX
    # PLY
    # PLB
    # PLD

    # Transfer Instructions
    #
    # TAX
    def tax # 0xAA
        if status_p_flag?(:x)
            @x = @a & 0xFF
            set_nz_flags(@x, true)
        else
            @x = @a & 0xFFFF
            set_nz_flags(@x, false)
        end
    end

    # TAY
    # TSX
    # TXS
    # TXA
    # TYA

    # TCD
    def tcd # 0x5B
        # A -> D (16 bits)
        @dp = @a & 0xFFFF
        set_nz_flags(@dp, false)
    end

    # TDC

    # TCS
    def tcs
        if emulation_mode
            @sp = 0x0100 | (@a & 0xFF)
        else
            @sp = @a & 0xFFFF
        end
    end


    # TSC
    # TXY
    # TYX

    # Block Moves
    # MVN
    # MVP

    # Exchange Instructions

    # XBA
    def xba # 0xEB
        low = @a & 0x00FF
        high = (@a & 0xFF00) >> 8

        @a = (low << 8) | high

        set_nz_flags(@a & 0x00FF, true)
    end

    # XCE
    # This instruction is the only means provided by the 65802 and 65816 to shift between 6502 emulation
    # mode and the full, sixteen-bit native mode.
    def xce
        carry = status_p_flag?(:c)
        set_p_flag(:c, @emulation_mode)

        if carry # Entering emulation mode
            @sp &= 0xFF
            @sp |= 0x0100          # force SP to page 1
            set_p_flag(:m, true)   # A in 8-bit mode
            set_p_flag(:x, true)   # X and Y in 8-bit mode
            @x &= 0xFF             # truncate X
            @y &= 0xFF             # truncate Y
        end

        @emulation_mode = carry
    end
end
