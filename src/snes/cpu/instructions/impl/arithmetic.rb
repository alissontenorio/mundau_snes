module Snes::CPU::Instructions::Arithmetic
    # Instructions for incrementing and decrementing memory
    # Unary operations: Add one or subtract one from the value in memory
    # Read-Modify-Write - set the n and z status flags to reflect the result of the operation
    # depending on whether the loaded number was negative (that is, had its high bit set), or was zero.
    # DEC

    # Single Byte Operand: Add one or subtract one from the value X or Y register
    # Execute in two cycles

    # DEX
    def dex
        if status_p_flag?(:x)
            @x = (@x - 1) & 0x00FF
            set_nz_flags(@x)
        else
            @x = (@x - 1) & 0xFFFF
            set_nz_flags(@x, false)
        end
    end

    # DEY

    # INC

    # Instruction   |  Opcode  |  Bytes  |  Cycles  |    Flags   |    Operation    |  Addressing Mode
    # INC A 	        0x1A 		 1 	        2      N-----Z-         INC A        	Accumulator
    def inc_a
        value = fetch_data

        if status_p_flag?(:m)
            @a = (@a & 0xFF00) | ((value + 1) & 0x00FF)
            set_nz_flags(@a, true)
        else
            @a = (value + 1) & 0xFFFF
            set_nz_flags(@a, false)
        end
    end

    # INX

    # === Opcode 0xE8 ─ INX (Increment X) =========================================
    #
    # Increments the X register.
    #
    # Mode: Implied
    # Bytes: 1
    # Cycles: 2 cycles (8-bit mode), 2 (+1*) cycles (16-bit mode)
    # * The extra cycle occurs only if X is in 16-bit mode and the instruction crosses a page boundary when fetching the opcode.
    #
    # Affected Flags:
    #   - N: Set if the result has the most significant bit set (bit 7 or bit 15)
    #   - Z: Set if the result is zero
    #
    # Notes:
    # - The size of X is controlled by the X flag (P register, bit 5)
    #     - X = 0 → X/Y registers are 16 bits
    #     - X = 1 → X/Y registers are 8 bits
    #
    # @return [void]
    def inx # 0xE8
        if status_p_flag?(:x)
            @x = (@x & 0xFF00) | ((@x + 1) & 0x00FF)
            set_nz_flags(@x, true)
        else
            @x = (@x + 1) & 0xFFFF
            set_nz_flags(@x, false)
        end
    end

    # INY
    def iny # 0xC8
        if status_p_flag?(:x)
            @y = (@y & 0xFF00) | ((@y + 1) & 0x00FF)
            set_nz_flags(@y, true)
        else
            @y = (@y + 1) & 0xFFFF
            set_nz_flags(@y, false)
        end
    end

    # ADC
    def adc_imm # 0x69
        operand = fetch_data
        carry_in = status_p_flag?(:c) ? 1 : 0

        if status_p_flag?(:m)
            acc = @a & 0xFF

            if status_p_flag?(:d) # Decimal
                result, carry_out = bcd_add_8bit(acc, operand, carry_in)
                set_p_flag(:v, false)
                @cycles += 1
            else
                result = acc + operand + carry_in
                carry_out = result > 0xFF
                set_p_flag(:v, (~(acc ^ operand) & (acc ^ result) & 0x80) != 0)
                result &= 0xFF
            end

            @a = (@a & 0xFF00) | result
            set_p_flag(:c, carry_out)
            set_nz_flags(result, true)
        else
            acc = @a & 0xFFFF

            if status_p_flag?(:d) # Decimal
                result, carry_out = bcd_add_16bit(acc, operand, carry_in)
                set_p_flag(:v, false)
                @cycles += 1
            else
                result = acc + operand + carry_in
                carry_out = result > 0xFFFF
                set_p_flag(:v, (~(acc ^ operand) & (acc ^ result) & 0x8000) != 0)
                result &= 0xFFFF
            end

            @a = result
            set_p_flag(:c, carry_out)
            set_nz_flags(result, false)

            @cycles += 1
        end
    end

    # SBC

    # CMP
    def cmp_abs # 0xCD
        address = fetch_data
        value = read_word(address)

        if status_p_flag?(:m)
            acc = @a & 0x00FF
            mem = value & 0x00FF
            result = acc - mem

            set_nz_flags(result, true)
            set_p_flag(:c, acc >= mem)
        else
            acc = @a & 0xFFFF
            mem = value
            result = acc - mem

            set_nz_flags(result, false)
            set_p_flag(:c, acc >= mem)
            @cycles += 1
        end
    end

    # CPX
    def cpx_imm # 0xE0
        operand = fetch_data(p_flag: :x)

        if status_p_flag?(:x)
            result = (@x & 0xFF) - operand

            set_nz_flags(result, true)
            set_p_flag(:c, (@x & 0xFF) >= operand)
        else
            result = (@x & 0xFFFF) - operand

            set_nz_flags(result, false)
            set_p_flag(:c, (@x & 0xFFFF) >= operand)
            @cycles += 1
        end
    end

    # CPY
    def cpy_imm # 0xE0
        operand = fetch_data(p_flag: :x)

        if status_p_flag?(:x)
            result = (@y & 0xFF) - operand

            set_nz_flags(result, true)
            set_p_flag(:c, (@y & 0xFF) >= operand)
        else
            result = (@y & 0xFFFF) - operand

            set_nz_flags(result, false)
            set_p_flag(:c, (@y & 0xFFFF) >= operand)
            @cycles += 1
        end
    end
end
