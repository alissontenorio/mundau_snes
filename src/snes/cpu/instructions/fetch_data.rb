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
                    when :direct_page_indirect_long_indexed_y
                        fetch_dp_indirect_long_index_y(p_flag:, force_8bit:)
                    when :direct_indexed_x
                        fetch_dp_index_x
                    when :accumulator
                        fetch_accumulator
                    else
                        raise "No mode reach"
                    end
                end

                def fetch_pc_relative
                    value = read_byte(@pc)
                    increment_pc!
                    converts_8bit_unsigned_to_signed(value)
                    # (@pc + offset) & 0xFFFF # Ensure 16 bits
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
                    @cycles += 1 if (@dp & 0xFF) != 0 # Add 1 cycle if Direct Page is unaligned
                    (@dp + offset) & 0xFFFF
                end

                def fetch_dp_indirect_long_index_y(p_flag: :m, force_8bit: false)
                    dp_offset = read_byte(@pc)  # Fetch the direct page offset (1 byte)
                    increment_pc!

                    # Read the long (24-bit) address from the direct page offset
                    base_addr = read_long(@dp + dp_offset)

                    # Calculate the effective address by adding the Y register (index)
                    effective_addr = (base_addr + @y) & 0xFFFFFF

                    @cycles += 1 if (@dp & 0xFF) != 0 # Add 1 cycle if Direct Page is unaligned

                    if force_8bit || status_p_flag?(p_flag)
                        read_byte(effective_addr)
                    else
                        read_word(effective_addr)
                    end
                end

                def fetch_dp_index_x
                    # Bank will always be 0 - Page 101 - Assembly programming w65c816
                    dp_offset = read_byte(@pc)
                    increment_pc!

                    if status_p_flag?(:x) # 8-bit index
                        offset = (dp_offset + @x) & 0xFF
                    else # 16-bit index
                        offset = (dp_offset + @x) & 0xFFFF
                    end

                    address = (@dp + offset) & 0xFFFF

                    @cycles += 1 if (@dp & 0xFF) != 0 # Add 1 cycle if Direct Page is unaligned

                    if status_p_flag?(:m)
                        read_byte(address)
                    else
                        read_word(address)
                    end
                end

                def fetch_accumulator
                    if status_p_flag?(:m)
                        @a & 0xFF
                    else
                        @a & 0xFFFF
                    end
                end
            end
        end
    end
end