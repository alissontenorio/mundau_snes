module Snes
    module APU
        module Instructions
            module FetchData
                # | **Bank Source** | **Addressing Modes**                                          |
                # | --------------- | ------------------------------------------------------------- |
                # | **PBR**         | Instruction fetch, PC-relative control flow                   |
                # | **Bank 0**      | Direct Page, Absolute, Stack-relative, Indirect JMP           |
                # | **DBR**         | All (dp), (dp),Y, \[abs],Y, (S),Y — i.e., indirect data modes |
                # | **Explicit**    | Long addressing, block moves, absolute long JMP/JSR           |
                def fetch_data(p_flag: :m, force_8bit: false)
                    case @current_opcode_data[1].addressing_mode
                    when :immediate
                        fetch_immediate(p_flag:, force_8bit:)
                    when :direct_page
                        fetch_direct_page
                    when :relative
                        fetch_pc_relative
                    else
                        raise "No mode reach"
                    end
                end

                def fetch_immediate(p_flag:, force_8bit:)
                    value = read_byte(@pc)     # Fetch immediate value (next byte after opcode)
                    increment_pc!
                    value
                end

                def fetch_direct_page
                    dp = read_byte(@pc)
                    increment_pc!
                    dp
                end

                def fetch_pc_relative
                    value = read_byte(@pc)
                    increment_pc!
                    converts_8bit_unsigned_to_signed(value)
                end
            end
        end
    end
end