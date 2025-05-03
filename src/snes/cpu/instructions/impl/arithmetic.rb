module Snes
    module CPU
        module Instructions
            module Arithmetic
                # Instructions for incrementing and decrementing memory
                # Unary operations: Add one or subtract one from the value in memory
                # Read-Modify-Write - set the n and z status flags to reflect the result of the operation
                # depending on whether the loaded number was negative (that is, had its high bit set), or was zero.
                # DEC
                # INC

                # Single Byte Operand: Add one or subtract one from the value X or Y register
                # Execute in two cycles
                # DEX
                # DEY
                # INX
                # INY

                # ADC
                # SBC
                # CMP
                def cmp_abs # 0xCD
                    address = fetch_data
                    value = read_16(address)

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
                # CPY

                # def adc_dp_x(dp, x)
                #     dp = dp + x
                # end
                #
                # def adc_sr_s(sr, s)
                #
                # end
                #
                # def adc_dp(dp)
                #
                # end

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
                def inx
                    if status_p_flag?(:x)
                        @x = (@x + 1) & 0x00FF
                        set_nz_flags(@x, true)
                    else
                        @x = (@x + 1) & 0xFFFF
                        set_nz_flags(@x, false)
                    end
                end
            end
        end
    end
end
