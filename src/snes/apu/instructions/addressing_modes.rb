module Snes
    module APU
        module Instructions
            class AddressingMode
                # Symbol: dp, Bytes: 2
                DIRECT_PAGE = :direct_page

                # Symbol: dp. dp, Bytes: 3 - It says it's operation are DIRECT_PAGE
                # 09 - or  - DIRECT_PAGE_TO_DP  - Direct Page
                # 29 - and - DIRECT_PAGE_TO_DP  - Direct Page
                # 49 - eor - DIRECT_PAGE_TO_DP  - Direct Page
                # 69 - cmp - DIRECT_PAGE_TO_DP  - Direct Page
                # 89 - adc - DIRECT_PAGE_TO_DP  - Direct Page
                # a9 - sbc - DIRECT_PAGE_TO_DP  - Direct Page
                # fa - mov - DIRECT_PAGE_TO_DP  - Direct Page
                DIRECT_PAGE_TO_DP = :direct_page_to_dp

                # Symbol dp+X, Bytes: 2 /  Direct Page Indexed by X
                X_INDEXED_DIRECT_PAGE = :x_indexed_direct_page

                # Symbol dp+Y, Bytes: 2 / Direct Page Indexed by Y
                Y_INDEXED_DIRECT_PAGE = :y_indexed_direct_page

                # Symbol: (X), Bytes: 1
                # 06 or  - Indirect = (x)  - Implied (type 1)
                # 26 and - Indirect = (x)  - Implied Indirect (type 1)
                # 46 eor - Indirect = (x)  - Implied Indirect (type 2)
                # 66 cmp - Indirect = (x)  - Implied Indirect (type 1)
                # 86 adc - Indirect = (x)  - Implied (type 1)
                # A6 SBC - Indirect = (x)  - Implied Indirect (type 1)
                # C6 MOV - Indirect = (x)  - Implied (type 1)
                # E6 MOV - Indirect = (x)  - Implied (type 1)
                INDIRECT = :indirect

                # Not on official SNES image Development manual (figure 3-8-3, page 3-8-9)
                # Has connections with INDIRECT
                # 0D - Push PSW
                # 1D - DEC X
                # 2D - PUSH A
                # 3D - INC X
                # 4D - PUSH X
                # 5D - MOV X,A
                # 6D - PUSH Y
                # 7D - MOV A, X
                # 9D - MOV X, SP
                # BD - MOV SP, X
                # DD - MOV A, Y
                # ED - NOTC 1, 3
                # FD - MOV Y, A
                # 01, 11, 21, 31, 41, 51, 61, 71, 81, 91, A1, B1, C1, D1, E1, F1 - TCALL
                # 00 - NOP
                # 20 - CLRP
                # 40 - SETP
                # 60 - CLRC
                # 80 - SETC
                # A0 - EI
                # C0 - DI
                # E0 - CLRV
                # DC - DEC Y
                # FC - INC Y
                # 0F - BRK
                # 4F - PCALL
                # 6F - RET
                # 7F - RETI
                # CF - MUL YA
                # DF - DAA A
                # EF - SLEEP
                # FF - STOP
                IMPLIED = :implied

                # Symbol: (X), (Y), Bytes: 1 - It says it's operation are Implied Indirect (type 1) or Implied (type 1)
                # 19 - or  - Indirect Page To Indirect Page - (x), (y) - Implied Indirect (type 1)
                # 39 - and - Indirect Page To Indirect Page - (x), (y) - Implied Indirect (type 1)
                # 59 - eor - Indirect Page To Indirect Page - (x), (y) - Implied Indirect (type 1)
                # 79 - cmp - Indirect Page To Indirect Page - (x), (y) - Implied Indirect (type 1)
                # 99 - adc - Indirect Page To Indirect Page - (x), (y) - Implied (type 1)
                # b9 - sbc - Indirect Page To Indirect Page - (x), (y) - Implied Indirect (type 1)
                INDIRECT_PAGE_TO_DP = :indirect_page_to_dp

                # Symbol: dp, #imm, Bytes: 3 / Direct Page Immediate / Immediate Data to Direct Page = d, #i
                IMMEDIATE_DATA_TO_DP = :immediate_data_to_dp

                # Symbol: dp.bit, Bytes: 2
                DIRECT_PAGE_BIT = :direct_page_bit

                # Symbol: (X)+, Bytes: 1 - It says it's operation are DIRECT_PAGE_BIT
                # 02 set1 Indirect auto-increment = (x)+   - Direct Page Bit
                # 12 clr1 Indirect auto-increment = (x)+   - Direct Page Bit
                # 22 set1 Indirect auto-increment = (x)+   - Direct Page Bit
                # 32 clr1 Indirect auto-increment = (x)+   - Direct Page Bit
                # 42 set1 Indirect auto-increment = (x)+   - Direct Page Bit
                # 52 clr1 Indirect auto-increment = (x)+   - Direct Page Bit
                # 62 set1 Indirect auto-increment = (x)+   - Direct Page Bit
                # 72 clr1 Indirect auto-increment = (x)+   - Direct Page Bit
                # 82 set1 Indirect auto-increment = (x)+   - Direct Page Bit
                # 92 clr1 Indirect auto-increment = (x)+   - Direct Page Bit
                # a2 set1 Indirect auto-increment = (x)+   - Direct Page Bit
                # b2 clr1 Indirect auto-increment = (x)+   - Direct Page Bit
                # c2 set1 Indirect auto-increment = (x)+   - Direct Page Bit
                # d2 clr1 Indirect auto-increment = (x)+   - Direct Page Bit
                # e2 set1 Indirect auto-increment = (x)+   - Direct Page Bit
                # f2 clr1 Indirect auto-increment = (x)+   - Direct Page Bit
                INDIRECT_AUTO_INCREMENT = :indirect_auto_increment

                # Symbol: dp.bit, rel, Bytes: 3
                DIRECT_PAGE_BIT_RELATIVE = :direct_page_bit_relative

                # Symbol: mem.bit, Bytes: 3
                ABSOLUTE_BOOLEAN_BIT = :absolute_boolean_bit

                # Symbol: !abs, Bytes: 3
                ABSOLUTE = :absolute

                # Symbol: !abs+X, Bytes: 3 / Absolute Indexed by X
                X_INDEXED_ABSOLUTE = :x_indexed_absolute

                # Symbol: !abs+y, Bytes: 3  / Absolute Indexed by Y
                Y_INDEXED_ABSOLUTE = :y_indexed_absolute

                # Symbol: [DP+X], Bytes: 2 / Direct Page Indexed Indirect by X
                X_INDEXED_INDIRECT = :x_indexed_indirect

                # Symbol: [DP+Y], Bytes: 2 / Direct Page Indirect Indexed by Y
                INDIRECT_Y_INDEXED_INDIRECT = :indirect_y_indexed_indirect




                # Not on official SNES image Development manual (figure 3-8-3, page 3-8-9)
                IMMEDIATE = :immediate
                ACCUMULATOR = :accumulator

                # 10 - BPL  - RELATIVE - Program Counter Relative
                # 30 - BMI  - RELATIVE - Program Counter Relative
                # 50 - BVC  - RELATIVE - Program Counter Relative
                # 70 - BVS  - RELATIVE - Program Counter Relative
                # 90 - BCC  - RELATIVE - Program Counter Relative
                # B0 - BCS  - RELATIVE - Program Counter Relative
                # D0 - BNE  - RELATIVE - Program Counter Relative
                # F0 - BEQ  - RELATIVE - Program Counter Relative
                # 6E - DBNZ - RELATIVE - Direct Page / Program Counter Relative
                # 2e - CBNE - RELATIVE - Direct Page / Program Counter Relative
                # FE - DBNZ - RELATIVE - Direct Page / Program Counter Relative
                # 2f - BRA  - RELATIVE - Program Counter Relative
                RELATIVE = :relative

                # STACK-X
                # STACK-Y
                # STACK-PSW
                # STACK-INTERRUPT
                # Those instructions are called Implied in docs
                # 4d - PUSH - Stack - X     - Implied
                # 6d - PUSH - Stack - Y     - Implied
                # 0d - PUSH - Stack - PSD     - Implied
                # CE - POP - Stack - X     - Implied
                # EE - POP - Stack - Y     - Implied
                # 8E - POP - Stack - PSD     - Implied
                # 0f - BRK - Stack - Interrupt      - Implied
                # 6f - RET - Stack     - Implied
                # 7f - RETI - Stack     - Implied

                # Uppermost Page called just implied
                # 4f - PCALL - Uppermost Page - Implied

                freeze
            end
        end
    end
end