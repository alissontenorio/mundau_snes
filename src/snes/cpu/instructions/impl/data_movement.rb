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
                    value = fetch_data

                    if status_p_flag?(:m) # 8-bit - emulation
                        @a = (@a & 0xFF00) | value # Store value into the low byte of A, keeping high byte intact
                        set_p_flag(:n, (value & 0x80) != 0)
                    else # 16-bit - native
                        @a = value
                        set_p_flag(:n, (value & 0x8000) != 0)
                        @cycles += 1
                    end

                    # Update Zero (Z) flag: set if value is zero
                    set_p_flag(:z, value == 0)
                end

                def sta_abs
                    address = fetch_data

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
                def tcd # 0x5B
                    # A -> D (16 bits)
                    @dp = @a & 0xFFFF

                    set_p_flag(:z, @dp == 0)
                    set_p_flag(:n, (@dp & 0x8000) != 0)
                end

                # TDC

                # TCS
                def tcs
                    if emulation_mode
                        @sp = 0x0100 | (@a & 0xFF)
                    else
                        @sp = @a & 0xFFFF
                    end
                end


                # TSC
                # TXY
                # TYX



                # STZ
                # Store Zero to Memory
                def stz_abs # 0x9C
                    address = fetch_data

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

                # Exchange Instructions
                # XBA

                # XCE
                # This instruction is the only means provided by the 65802 and 65816 to shift between 6502 emulation
                # mode and the full, sixteen-bit native mode.
                def xce
                    carry = status_p_flag?(:c)
                    set_p_flag(:c, @emulation_mode)

                    if carry # Entering emulation mode
                        @sp &= 0xFF
                        @sp |= 0x0100          # force SP to page 1
                        set_p_flag(:m, true)   # A in 8-bit mode
                        set_p_flag(:x, true)   # X and Y in 8-bit mode
                        @x &= 0xFF             # truncate X
                        @y &= 0xFF             # truncate Y
                    end

                    @emulation_mode = carry
                end
            end
        end
    end
end
