module Snes::CPU::Instructions::ControlFlow
    # Instruction
    # JMP
    # JML

    # BRA
    def bra # 0x80
        offset = fetch_data

        @pc = (@pc + offset) & 0xFFFF # Ensure 16 bits
    end

    # BRL
    # BPL
    # BMI
    # BVC
    # BVS
    # BCC
    # BCS


    # BNE
    def bne # 0xD0
        offset = fetch_data

        unless status_p_flag?(:z) # if flag is 0 jump occurs
            @pc = (@pc + offset) & 0xFFFF # Ensure 16 bits
            @cycles += 1
        end
    end

    # BEQ
    # PER
end
