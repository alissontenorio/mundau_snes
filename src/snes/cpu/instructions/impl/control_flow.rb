module Snes::CPU::Instructions::ControlFlow
    # Instruction
    # JMP
    # JML

    # BRA
    def bra # 0x80
        offset = converts_8bit_unsigned_to_signed(read_byte(@pc))
        increment_pc!

        @pc = @pc + offset
    end

    # BRL
    # BPL
    # BMI
    # BVC
    # BVS
    # BCC
    # BCS


    # BNE
    def bne
        offset = converts_8bit_unsigned_to_signed(read_byte(@pc))
        increment_pc!

        unless status_p_flag?(:z) # if flag is 0 jump occurs
            @pc = @pc + offset
            @cycles += 1
        end
    end

    # BEQ
    # PER
end
