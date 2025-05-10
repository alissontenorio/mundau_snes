module Snes
    module CPU
        module Instructions
            module FetchData
                # | **Bank Source** | **Addressing Modes**                                          |
                # | --------------- | ------------------------------------------------------------- |
                # | **PBR**         | Instruction fetch, PC-relative control flow                   |
                # | **Bank 0**      | Direct Page, Absolute, Stack-relative, Indirect JMP           |
                # | **DBR**         | All (dp), (dp),Y, \[abs],Y, (S),Y — i.e., indirect data modes |
                # | **Explicit**    | Long addressing, block moves, absolute long JMP/JSR           |
                def fetch_data(p_flag: :m, force_8bit: false)
                    case @current_opcode_data.addressing_mode
                    when :immediate
                        fetch_immediate(p_flag:, force_8bit:) # uses pbr
                    when :absolute
                        fetch_absolute  # bank 0
                    when :direct_page
                        fetch_direct_page # bank 0
                    when :stack_push
                        nil
                    when :program_counter_relative
                        fetch_pc_relative
                    else
                        raise "No mode reach"
                    end
                end

                def fetch_pc_relative
                    value = read_byte(@pc)
                    offset = converts_8bit_unsigned_to_signed(value)
                    increment_pc!
                    (@pc + offset) & 0xFFFF # Ensure 16 bits
                end

                def fetch_immediate(p_flag: :m, force_8bit: false)
                    if force_8bit || status_p_flag?(p_flag) # 8-bit - emulation
                        value = read_byte(full_pc(@pbr))
                        increment_pc!
                    else # 16-bit - native
                        # bytes_used + 1
                        value = read_word(full_pc(@pbr))
                        increment_pc!(2)
                    end
                    value
                end

                def fetch_absolute
                    value = read_word(@pc)  # Fetch 16-bit absolute address
                    increment_pc!(2)    # Move PC forward by 2 bytes
                    value
                end

                def fetch_direct_page
                    offset = read_byte(@pc)
                    increment_pc!
                    (@dp + offset) & 0xFFFF
                end
            end
        end
    end
end