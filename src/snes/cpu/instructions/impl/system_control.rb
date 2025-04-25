module Snes
    module CPU
        module Instructions
            module SystemControl
                # Interrupts and System Control Instructions
                # BRK
                # RTI
                # NOP
                # SEC
                # CLC
                # SED
                # CLD
                # SEI
                # CLI
                # CLV
                # SEP
                # REP
                # COP
                # STP
                # WAI
                # WDM

                # === Opcode 0x78 ─ SEI (Set Interrupt Disable) =========================================
                #
                # Sets the Interrupt Disable (I) flag in the P register, disabling interrupts.
                # This instruction prevents the CPU from responding to interrupts until the
                # Interrupt Disable flag is cleared.
                #
                # Mode:          Implied
                # Size:          1 byte, 2 cycles
                # Flags Affected: I (Interrupt Disable)
                #
                # === Operation:
                #   - The Interrupt Disable (I) flag is set to 1, disabling interrupts.
                #   - No other flags in the P register are affected.
                #
                # === Example:
                #   SEI  # Disables interrupts by setting the Interrupt Disable flag (I)
                #
                # === Usage:
                #   SEI is used when the CPU needs to prevent interrupts during critical code execution
                #   to ensure uninterrupted processing.
                #
                # === Note:
                #   - This instruction does not modify the program counter (PC) or any other processor state.
                #   - Interrupts remain disabled until the SEI is cleared by instructions like CLI (Clear Interrupt Disable).
                def sei
                    set_p_flag(:i, true)
                end
            end
        end
    end
end
