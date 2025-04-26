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

                # Block Moves
                # MVN
                # MVP

                def stz_absolute
                    offset = read_16
                    address = address_with_dbr(offset)

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
            end
        end
    end
end
