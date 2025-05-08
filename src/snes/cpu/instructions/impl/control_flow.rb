module Snes::CPU::Instructions::ControlFlow
    # Instruction
    # JMP
    # JML
    # BRA
    # BRL
    # BPL
    # BMI
    # BVC
    # BVS
    # BCC
    # BCS


    # BNE
    def bne
        offset = converts_8bit_unsigned_to_signed(read_8(@pc))
        increment_pc!

        unless status_p_flag?(:z) # if flag is 0 jump occurs
            @pc = (@pc + offset) & 0xFFFF
            @cycles += 1
        end
    end

    # BEQ
    # PER
end
