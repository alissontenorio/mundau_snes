module Snes
    module CPU
        module Instructions
            module SystemControl
                # Interrupts and System Control Instructions
                # NOP

                # SEC
                # SED
                # CLD
                # CLI
                # CLV
                # STP

                # SEP
                def sep # 0xE2
                    value = fetch_immediate(force_8bit: true)

                    @p |= value
                    if emulation_mode
                        set_p_flag(:m, true)
                        set_p_flag(:x, true)
                    end
                end


                # REP
                def rep # 0xC2
                    value = fetch_immediate(force_8bit: true)

                    @p &= ~value & 0xFF      # Clear the bits in the P register where value is 1
                    if emulation_mode
                        set_p_flag(:m, false)  # Accumulator must be 16-bit
                        set_p_flag(:x, false)  # Index registers must be 16-bit
                    end
                end

                # STP
                # WAI
                # WDM

                # SEI 0x78
                def sei
                    set_p_flag(:i, true)
                end

                # CLC
                def clc
                    set_p_flag(:c, false)
                end
            end
        end
    end
end
