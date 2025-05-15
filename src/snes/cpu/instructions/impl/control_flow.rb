module Snes::CPU::Instructions::ControlFlow
    # Instruction
    # JMP
    # JML

    # BRA
    def bra # 0x80
        offset = fetch_data

        old_pc = @pc
        @pc = (@pc + offset) & 0xFFFF # Ensure 16 bits
        increment_cycles_if_page_crossing(old_pc)
    end

    # BRL
    # BPL
    # BMI
    # BVC

    # BVS
    def bvs # 0x70
        offset = fetch_data

        if status_p_flag?(:v)
            old_pc = @pc
            @pc = (@pc + offset) & 0xFFFF
            increment_cycles_if_page_crossing(old_pc)
            @cycles += 1
        end
    end

    # BCC
    # BCS


    # BNE
    def bne # 0xD0
        offset = fetch_data

        unless status_p_flag?(:z) # if flag is 0 jump occurs
            old_pc = @pc
            @pc = (@pc + offset) & 0xFFFF # Ensure 16 bits
            increment_cycles_if_page_crossing(old_pc)
            @cycles += 1
        end
    end

    # BEQ

    # Instruction       |  Opcode  |  Bytes  |  Cycles  |    Flags   |      Operation      |    Addressing Mode
    # BEQ nearlabel     	0xF0          2 	     2    --------       Branch if Equal 	  Program Counter Relative
    def beq
        offset = fetch_data

        if status_p_flag?(:z) # if flag is 1 jump occurs
            old_pc = @pc
            @pc = (@pc + offset) & 0xFFFF # Ensure 16 bits
            increment_cycles_if_page_crossing(old_pc)
            @cycles += 1
        end
    end

    # PER
end
