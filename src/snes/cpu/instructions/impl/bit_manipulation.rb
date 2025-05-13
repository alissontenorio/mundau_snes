module Snes::CPU::Instructions::BitManipulation
    # BIT
    # TRB
    # TSB
    # ASL
    # LSR

    # ROL
    def rol_a # 0x2A
        value = fetch_data

        old_carry = status_p_flag?(:c) ? 0x1 : 0

        if status_p_flag?(:m)
            new_carry = value & 0x80
            result = ((value << 1) | old_carry) & 0xFF
            @a = (@a & 0xFF00) | result
            set_nz_flags(result, true)
        else
            new_carry = value & 0x8000
            result = ((value << 1) | old_carry)  & 0xFFFF
            @a = result
            set_nz_flags(result, false)
        end

        set_p_flag(:c, new_carry != 0)
    end

    # ROR
    def ror_dp_x # 0x76
        value = fetch_data

        new_carry = value & 0x01

        if status_p_flag?(:m)
            old_carry = status_p_flag?(:c) ? 0x80 : 0
            result = (value >> 1) | old_carry
            write_byte(address, result & 0xFF)
            set_nz_flags(result, true)
        else
            old_carry = status_p_flag?(:c) ? 0x8000 : 0
            result = (value >> 1) | old_carry
            write_word(address, result & 0xFFFF)
            set_nz_flags(result, false)
            @cycles += 2
        end

        set_p_flag(:c, new_carry != 0)
    end
end
