module Snes
    module CPU
        module Instructions
            module DataMovement
                # Load/Store Instructions
                # LDA
                # LDX
                # LDY
                # STA
                # STX
                # STY

                def lda_immediate # 0xA9
                    if status_p_flag?(:m) # 8-bit - emulation
                        value = read_8
                        increment_pc!
                        @a = (@a & 0xFF00) | value # Store value into the low byte of A, keeping high byte intact
                        set_p_flag(:n, (value & 0x80) != 0)
                    else # 16-bit - native
                        value = read_16
                        increment_pc!(2)
                        @a = value
                        set_p_flag(:n, (value & 0x8000) != 0)
                        @cycles += 1
                    end

                    # Update Zero (Z) flag: set if value is zero
                    set_p_flag(:z, value == 0)
                end

                # def lda_absolute
                #     # Read the 16-bit address from the instruction stream
                #     address = read_16
                #     increment_pc(2) # Because read_16 manually reads bytes, but your PC still needs to move forward
                #
                #     # Form the full address by combining PBR and the 16-bit address
                #     full_address = (@pbr << 16) | address
                #
                #     # Check M flag to know if accumulator is 8-bit or 16-bit
                #     if status_p_flag?(:m)
                #         value = read_8(full_address)
                #         @a = (@a & 0xFF00) | value # Only update low byte if 8-bit
                #         set_p_flag(:n, (value & 0x80) != 0) # Set Negative flag
                #         set_p_flag(:z, value == 0)          # Set Zero flag
                #     else
                #         lo = read_8(full_address)
                #         hi = read_8(full_address + 1)
                #         value = (hi << 8) | lo
                #         @a = value
                #         set_p_flag(:n, (value & 0x8000) != 0)
                #         set_p_flag(:z, value == 0)
                #     end
                #
                #     # This instruction normally consumes 4 cycles
                #     increment_cycles(4)
                # end

                def sta_abs
                    address = read_16  # Fetch 16-bit absolute address
                    increment_pc!(2)    # Move PC forward by 2 bytes

                    if status_p_flag?(:m) # 8-bit accumulator mode
                        value = @a & 0x00FF  # Use only the low 8 bits of A
                        write_8(address, value)
                    else # 16-bit accumulator mode
                        value = @a & 0xFFFF  # Use full 16 bits of A
                        write_16(address, value)

                        @cycles += 1
                    end
                end

                # Push Instructions
                # PHA
                # PHP
                # PHX
                # PHY
                # PHB
                # PHK
                # PHD

                # Push Instructions Introduced
                # PEA
                # PEI
                # PER

                # Pull Instructions
                # PLA
                # PLP
                # PLX
                # PLY
                # PLB
                # PLD

                # Transfer Instructions
                # TAX
                # TAY
                # TSX
                # TXS
                # TXA
                # TYA
                # TCD
                # TDC
                # TCS

                # TSC
                # TXY
                # TYX

                # Exchange Instructions
                # XBA
                # XCE

                # Store Zero to Memory
                # STZ

                def stz_abs
                    offset = read_16
                    address = address_with_dbr(offset)

                    increment_pc!(2)

                    if status_p_flag?(:m)
                        write_8(address, 0x00) # emulation mode
                    else
                        write_16(address, 0x0000) # native mode
                        @cycles += 1
                    end
                end

                def stz_dp
                    offset = read_8           # Fetch 8-bit offset
                    address = address_direct_page(offset)    # Compute effective 24-bit address

                    if status_p_flag?(:m)
                        write_8(address, 0x00) # emulation mode
                    else
                        write_16(address, 0x0000) # native mode
                        @cycles += 1 # Add 1 cycle if M flag is 0 (16-bit mode)
                    end

                    @cycles += 1 if (@dp & 0x00FF) != 0x00   # Add 1 if DP low byte is not zero

                    @cycles += (@dp == 0 ? 3 : 4)
                end

                # Block Moves
                # MVN
                # MVP
            end
        end
    end
end
