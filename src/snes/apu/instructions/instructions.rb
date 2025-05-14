module Snes
    module APU
        module Instructions
            # implement this, current to implement: e4
            # cd, bd, e8, c6, 1d, d0, 8f, 78, 2f, eb, 7e, e4, cb, d7, fc, ab, 10, ba, da, c4, dd, 5d, 1f, c0
            # cb, d7, fc, ab, 10, c0

            # 2F 19 - Bra rel                - Feito
            # EB F4 - Mov Y, dp              - Feito
            # D0 FC - BNE Rel                - Feito
            # 7E F4 - CMP Y, dp              - Feito
            # D0 0B - BNE rel                - Feito
            # E4 F5 - MOV A, dp              - Feito
            # CB F4 - MOV dp, Y
            # D7 00 - MOV [dp]+Y, A
            # FC - INC Y
            # D0 F3 - BNE Rel                - Feito
            # AB 01 - INC dp
            # 10 EF - BPL rel
            # 7E F4 - CMP Y, dp
            # 10 EB - BPL rel
            # BA F6 - MOVW YA, dp            - Feito
            # DA 00 - MOVW dp, YA            - Feito
            # BA F4 - MOVW YA, dp            - Feito
            # C4 F4 - MOV dp, A              - Feito
            # DD - MOV A, Y                  - Feito
            # 5D - MOV X, A                  - Feito
            # D0 DB - BNE rel                - Feito
            # 1F 00 00 - JMP [!abs+X]
            # C0

            # Instruction   |  Opcode  |   In 65816   |  Bytes  |  Cycles  |    Flags   |  Operation  | Addressing Mode
            # MOV X, #imm	     0xCD	   LDX #imm          2	      2	      N-----Z-      X <- imm          Immediate
            def mov_x_imm
                value = fetch_data
                @x = value
                set_nz_flags(value)
            end

            # Instruction   |  Opcode  |   In 65816   |  Bytes  |  Cycles  |    Flags   |  Operation  | Addressing Mode
            # MOV A, #imm       0xE8       LDA #imm          2         2     N.....Z.      A <- imm          Immediate
            def mov_a_imm
                value = fetch_data
                @a = value
                set_nz_flags(value)
            end

            # Instruction   |  Opcode  |   In 65816   |  Bytes  |  Cycles  |    Flags   |   Operation   | Addressing Mode
            # MOV Y, dp        0xEB         LDY dp          2          3      N.....Z.      Y <- (dp)      Direct Page
            def mov_y_dp
                dp = fetch_data
                @y = read_byte(dp)
                set_nz_flags(@y)
            end

            # Instruction   |  Opcode  |   In 65816   |  Bytes  |  Cycles  |    Flags   |   Operation   | Addressing Mode
            #  MOV A, dp       0xE4        LDA dp           2          3      N.....Z.      A <- (dp)     Direct Page
            def mov_a_dp
                dp = fetch_data
                @a = read_byte(dp)
                set_nz_flags(@a)
            end

            # Instruction   |  Opcode  |   In 65816   |  Bytes  |  Cycles  |    Flags   |   Operation   | Addressing Mode
            # MOV (X), A        0xC6                        1           4     ........      A -> (X)    Implied type 1 (INDIRECT = (X))
            def mov_ind_x_a
                write_byte(@x, @a)
            end

            # Instruction   |  Opcode  |   In 65816   |  Bytes  |  Cycles  |    Flags   |   Operation   | Addressing Mode
            # MOV dp, A         0xC4        STA dp          2          4       ........     A -> (dp)     Direct Page
            def mov_dp_a
                dp = fetch_data
                write_byte(dp, @a)
            end

            # Instruction   |  Opcode  |   In 65816   |  Bytes  |  Cycles  |    Flags   |   Operation   | Addressing Mode
            # MOV dp, Y         0xCB        STY dp         2           4      ........      Y -> (dp)     Direct Page
            def mov_dp_y
                dp = fetch_data
                write_byte(dp, y)
            end

            # Instruction   |  Opcode  |   In 65816   |  Bytes  |  Cycles  |    Flags   |   Operation   | Addressing Mode
            # MOV	SP, X	     0xBD	        TXS          1	       2	  --------      SP <- X     Implied type 1 (INDIRECT = (X))
            def mov_sp_x
                @sp = @x
            end

            # Instruction   |  Opcode  |   In 65816   |  Bytes  |  Cycles  |    Flags   |   Operation   | Addressing Mode
            # MOV A, Y          0xDD           TYA          1          2      N.....Z.       A <- Y       Implied (type 1) (Implied)
            def mov_a_y
                @a = @y

                set_nz_flags(@a)
            end

            # Instruction   |  Opcode  |   In 65816   |  Bytes  |  Cycles  |    Flags   |   Operation   | Addressing Mode
            # MOV X, A          0x5D          TAX           1          2      N.....Z.       X <- A     Implied (type 1) (Implied)
            def mov_x_a
                @x = @a

                set_nz_flags(@x)
            end

            # Instruction   |  Opcode  |   In 65816   |  Bytes  |  Cycles  |    Flags   |   Operation   | Addressing Mode
            # MOV dp, #imm      0x8F            ?            3         5      ........     (dp) <- imm    IMMEDIATE_DATA_TO_DP
            def mov_ind_dp_imm
                imm = read_byte(@pc)
                increment_pc!
                dp = read_byte(@pc) # address
                increment_pc!

                write_byte(dp, imm)
            end

            # Instruction   |  Opcode  |   In 65816   |  Bytes  |  Cycles  |    Flags   |   Operation   | Addressing Mode
            # MOVW YA, dp       0xBA            ?           2          5      N.....Z.  YA <- (dp+1)(dp)  Direct Page
            def movw_ya_dp # 0xBA
                dp = fetch_data

                @a = read_byte(dp)
                @y = read_byte((dp + 1) & 0xFF)

                value = (@y << 8) | @a
                set_nz_flags(value, false)
            end

            # Instruction   |  Opcode  |   In 65816   |  Bytes  |  Cycles  |    Flags   |   Operation   | Addressing Mode
            # MOVW dp, YA      0xDA          ?              2          4      ........  (dp+1)(dp) <- YA  Direct Page
            def movw_dp_ya
                dp = fetch_data

                write_byte(dp, @a)
                write_byte((dp + 1) & 0xFF, @y)
            end

            # Instruction   |  Opcode  |   In 65816   |  Bytes  |  Cycles  |    Flags   |   Operation   | Addressing Mode
            # DEC X             0x1D           DEX            1         2      N.....Z.      -- X       Implied type 1 (Implied)
            def dec_x
                @x = (@x - 1) & 0xFF
                set_nz_flags(@x)
            end

            # Instruction   |  Opcode  |   In 65816   |  Bytes  |  Cycles  |    Flags   |   Operation   | Addressing Mode
            # BNE rel           0xD0        BNE rel          2        2/4     ........    Branch if Z=0   Relative (PC Relative)
            def bne_rel
                offset = fetch_data

                unless status_p_flag?(:z)
                    @pc = (@pc + offset) & 0xFFFF
                    @cycles += 2
                end
            end

            # Instruction   |  Opcode  |   In 65816   |  Bytes  |  Cycles  |    Flags   |   Operation   | Addressing Mode
            # BRA rel           0x2F       BRA rel         2          4      ........     Branch always   Program Counter Relative
            def bra_rel
                offset = fetch_data

                @pc = (@pc + offset) & 0xFFFF
            end

            # Instruction   |  Opcode  |   In 65816   |  Bytes  |  Cycles  |    Flags   |   Operation   | Addressing Mode
            # CMP dp, #imm      0x78             ?          3          5      N.....ZC     (dp) - imm     IMMEDIATE_DATA_TO_DP
            def cmp_ind_dp_imm
                imm = read_byte(@pc)
                increment_pc!
                dp = read_byte(@pc)
                increment_pc!

                value = read_byte(dp)
                result = (value - imm) & 0xFF

                set_p_flag(:c, value >= imm)
                set_nz_flags(result)
            end

            # Instruction   |  Opcode  |   In 65816   |  Bytes  |  Cycles  |    Flags   |   Operation   | Addressing Mode
            # CMP Y, dp         0x7E        CPY dp          2          3      N.....ZC      Y - (dp)        Direct Page
            def cmp_y_dp
                dp = fetch_data

                value = read_byte(dp)
                result = (@y - value) & 0xFF

                set_p_flag(:c, @y >= value)
                set_nz_flags(result)
            end

            # Instruction   |  Opcode  |   In 65816   |  Bytes  |  Cycles  |    Flags   |   Operation   | Addressing Mode
            # JMP [!abs+X]      0x1F     JMP (abs, X)       3         6       ........ PC<-(abs+X+1)(abs+X)  Absolute (Absolute Indexed by X)
            def jmp_abs_x
                base_addr = read_word(@pc)
                increment_pc!(2) # toDo: remove this

                effective_addr = (base_addr + @x) & 0xFFFF

                target_addr = read_word(effective_addr)

                @pc = target_addr
            end
        end
    end
end


# +---------------------------------------------------------------+------------------+--------+-------+--------+----------+----------------------------------------------+
# |                          Instruction                          |    6502-Style    | Opcode | Bytes | Cycles |  Flags   |                    Notes                     |
# +---------------------------------------------------------------+------------------+--------+-------+--------+----------+----------------------------------------------+
# | . 8-bit move memory to register                               |                  |        |       |        |          |                                              |
# | MOV A, #imm                                                   | LDA #imm         | E8     |     2 | 2      | N.....Z. |                                              |
# | MOV A, (X)                                                    | ?                | E6     |     1 | 3      | N.....Z. |                                              |
# | MOV A, (X)+                                                   | ?                | BF     |     1 | 4      | N.....Z. | X++ after read                               |
# | MOV A, dp                                                     | LDA dp           | E4     |     2 | 3      | N.....Z. |                                              |
# | MOV A, dp+X                                                   | LDA dp, X        | F4     |     2 | 4      | N.....Z. |                                              |
# | MOV A, !abs                                                   | LDA abs          | E5     |     3 | 4      | N.....Z. |                                              |
# | MOV A, !abs+X                                                 | LDA abs, X       | F5     |     3 | 5      | N.....Z. |                                              |
# | MOV A, !abs+Y                                                 | LDA abs, Y       | F6     |     3 | 5      | N.....Z. |                                              |
# | MOV A, [dp+X]                                                 | LDA (dp, X)      | E7     |     2 | 6      | N.....Z. |                                              |
# | MOV A, [dp]+Y                                                 | LDA (dp), Y      | F7     |     2 | 6      | N.....Z. |                                              |
# | MOV X, #imm                                                   | LDX #imm         | CD     |     2 | 2      | N.....Z. |                                              |
# | MOV X, dp                                                     | LDX dp           | F8     |     2 | 3      | N.....Z. |                                              |
# | MOV X, dp+Y                                                   | LDX dp, Y        | F9     |     2 | 4      | N.....Z. |                                              |
# | MOV X, !abs                                                   | LDX abs          | E9     |     3 | 4      | N.....Z. |                                              |
# | MOV Y, #imm                                                   | LDY #imm         | 8D     |     2 | 2      | N.....Z. |                                              |
# | MOV Y, dp                                                     | LDY dp           | EB     |     2 | 3      | N.....Z. |                                              |
# | MOV Y, dp+X                                                   | LDY dp, X        | FB     |     2 | 4      | N.....Z. |                                              |
# | MOV Y, !abs                                                   | LDY abs          | EC     |     3 | 4      | N.....Z. |                                              |
# | . 8-bit move register to memory                               |                  |        |       |        |          |                                              |
# | MOV (X), A                                                    | ?                | C6     |     1 | 4      | ........ |                                              |
# | MOV (X)+, A                                                   | ?                | AF     |     1 | 4      | ........ | X++ after read                               |
# | MOV dp, A                                                     | STA dp           | C4     |     2 | 4      | ........ |                                              |
# | MOV dp+X, A                                                   | STA dp, X        | D4     |     2 | 5      | ........ |                                              |
# | MOV !abs, A                                                   | STA abs          | C5     |     3 | 5      | ........ |                                              |
# | MOV !abs+X, A                                                 | STA abs, X       | D5     |     3 | 6      | ........ |                                              |
# | MOV !abs+Y, A                                                 | STA abs, Y       | D6     |     3 | 6      | ........ |                                              |
# | MOV [dp+X], A                                                 | STA (dp, X)      | C7     |     2 | 7      | ........ |                                              |
# | MOV [dp]+Y, A                                                 | STA (dp), Y      | D7     |     2 | 7      | ........ |                                              |
# | MOV dp, X                                                     | STX dp           | D8     |     2 | 4      | ........ |                                              |
# | MOV dp+Y, X                                                   | STX dp, Y        | D9     |     2 | 5      | ........ |                                              |
# | MOV !abs, X                                                   | STX abs          | C9     |     3 | 5      | ........ |                                              |
# | MOV dp, Y                                                     | STY dp           | CB     |     2 | 4      | ........ |                                              |
# | MOV dp+X, Y                                                   | STY dp, X        | DB     |     2 | 5      | ........ |                                              |
# | MOV !abs, Y                                                   | STY abs          | CC     |     3 | 5      | ........ |                                              |
# | . 8-bit move register to register / special direct page moves |                  |        |       |        |          |                                              |
# | MOV A, X                                                      | TXA              | 7D     |     1 | 2      | N.....Z. |                                              |
# | MOV A, Y                                                      | TYA              | DD     |     1 | 2      | N.....Z. |                                              |
# | MOV X, A                                                      | TAX              | 5D     |     1 | 2      | N.....Z. |                                              |
# | MOV Y, A                                                      | TAY              | FD     |     1 | 2      | N.....Z. |                                              |
# | MOV X, SP                                                     | TSX              | 9D     |     1 | 2      | N.....Z. |                                              |
# | MOV SP, X                                                     | TXS              | BD     |     1 | 2      | ........ |                                              |
# | MOV dp, dp                                                    | ?                | FA     |     3 | 5      | ........ |                                              |
# | MOV dp, #imm                                                  | ?                | 8F     |     3 | 5      | ........ |                                              |
# | . 8-bit arithmetic                                            |                  |        |       |        |          |                                              |
# | ADC A, #imm                                                   | ADC #imm         | 88     |     2 | 2      | NV..H.ZC |                                              |
# | ADC A, (X)                                                    | ?                | 86     |     1 | 3      | NV..H.ZC |                                              |
# | ADC A, dp                                                     | ADC dp           | 84     |     2 | 3      | NV..H.ZC |                                              |
# | ADC A, dp+X                                                   | ADC dp, X        | 94     |     2 | 4      | NV..H.ZC |                                              |
# | ADC A, !abs                                                   | ADC abs          | 85     |     3 | 4      | NV..H.ZC |                                              |
# | ADC A, !abs+X                                                 | ADC abs, X       | 95     |     3 | 5      | NV..H.ZC |                                              |
# | ADC A, !abs+Y                                                 | ADC abs, Y       | 96     |     3 | 5      | NV..H.ZC |                                              |
# | ADC A, [dp+X]                                                 | ADC (dp, X)      | 87     |     2 | 6      | NV..H.ZC |                                              |
# | ADC A, [dp]+Y                                                 | ADC (dp), Y      | 97     |     2 | 6      | NV..H.ZC |                                              |
# | ADC (X), (Y)                                                  | ?                | 99     |     1 | 5      | NV..H.ZC |                                              |
# | ADC dp, dp                                                    | ?                | 89     |     3 | 6      | NV..H.ZC |                                              |
# | ADC dp, #imm                                                  | ?                | 98     |     3 | 5      | NV..H.ZC |                                              |
# | SBC A, #imm                                                   | SBC #imm         | A8     |     2 | 2      | NV..H.ZC |                                              |
# | SBC A, (X)                                                    | ?                | A6     |     1 | 3      | NV..H.ZC |                                              |
# | SBC A, dp                                                     | SBC dp           | A4     |     2 | 3      | NV..H.ZC |                                              |
# | SBC A, dp+X                                                   | SBC dp, X        | B4     |     2 | 4      | NV..H.ZC |                                              |
# | SBC A, !abs                                                   | SBC abs          | A5     |     3 | 4      | NV..H.ZC |                                              |
# | SBC A, !abs+X                                                 | SBC abs, X       | B5     |     3 | 5      | NV..H.ZC |                                              |
# | SBC A, !abs+Y                                                 | SBC abs, Y       | B6     |     3 | 5      | NV..H.ZC |                                              |
# | SBC A, [dp+X]                                                 | SBC (dp, X)      | A7     |     2 | 6      | NV..H.ZC |                                              |
# | SBC A, [dp]+Y                                                 | SBC (dp), Y      | B7     |     2 | 6      | NV..H.ZC |                                              |
# | SBC (X), (Y)                                                  | ?                | B9     |     1 | 5      | NV..H.ZC |                                              |
# | SBC dp, dp                                                    | ?                | A9     |     3 | 6      | NV..H.ZC |                                              |
# | SBC dp, #imm                                                  | ?                | B8     |     3 | 5      | NV..H.ZC |                                              |
# | CMP A, #imm                                                   | CMP #imm         | 68     |     2 | 2      | N.....ZC |                                              |
# | CMP A, (X)                                                    | ?                | 66     |     1 | 3      | N.....ZC |                                              |
# | CMP A, dp                                                     | CMP dp           | 64     |     2 | 3      | N.....ZC |                                              |
# | CMP A, dp+X                                                   | CMP dp, X        | 74     |     2 | 4      | N.....ZC |                                              |
# | CMP A, !abs                                                   | CMP abs          | 65     |     3 | 4      | N.....ZC |                                              |
# | CMP A, !abs+X                                                 | CMP abs, X       | 75     |     3 | 5      | N.....ZC |                                              |
# | CMP A, !abs+Y                                                 | CMP abs, Y       | 76     |     3 | 5      | N.....ZC |                                              |
# | CMP A, [dp+X]                                                 | CMP (dp, X)      | 67     |     2 | 6      | N.....ZC |                                              |
# | CMP A, [dp]+Y                                                 | CMP (dp), Y      | 77     |     2 | 6      | N.....ZC |                                              |
# | CMP (X), (Y)                                                  | ?                | 79     |     1 | 5      | N.....ZC |                                              |
# | CMP dp, dp                                                    | ?                | 69     |     3 | 6      | N.....ZC |                                              |
# | CMP dp, #imm                                                  | ?                | 78     |     3 | 5      | N.....ZC |                                              |
# | CMP X, #imm                                                   | CPX #imm         | C8     |     2 | 2      | N.....ZC |                                              |
# | CMP X, dp                                                     | CPX dp           | 3E     |     2 | 3      | N.....ZC |                                              |
# | CMP X, !abs                                                   | CPX abs          | 1E     |     3 | 4      | N.....ZC |                                              |
# | CMP Y, #imm                                                   | CPY #imm         | AD     |     2 | 2      | N.....ZC |                                              |
# | CMP Y, dp                                                     | CPY dp           | 7E     |     2 | 3      | N.....ZC |                                              |
# | CMP Y, !abs                                                   | CPY abs          | 5E     |     3 | 4      | N.....ZC |                                              |
# | . 8-bit boolean logic                                         |                  |        |       |        |          |                                              |
# | AND A, #imm                                                   | AND #imm         | 28     |     2 | 2      | N.....Z. |                                              |
# | AND A, (X)                                                    | ?                | 26     |     1 | 3      | N.....Z. |                                              |
# | AND A, dp                                                     | AND dp           | 24     |     2 | 3      | N.....Z. |                                              |
# | AND A, dp+X                                                   | AND dp, X        | 34     |     2 | 4      | N.....Z. |                                              |
# | AND A, !abs                                                   | AND abs          | 25     |     3 | 4      | N.....Z. |                                              |
# | AND A, !abs+X                                                 | AND abs, X       | 35     |     3 | 5      | N.....Z. |                                              |
# | AND A, !abs+Y                                                 | AND abs, Y       | 36     |     3 | 5      | N.....Z. |                                              |
# | AND A, [dp+X]                                                 | AND (dp, X)      | 27     |     2 | 6      | N.....Z. |                                              |
# | AND A, [dp]+Y                                                 | AND (dp), Y      | 37     |     2 | 6      | N.....Z. |                                              |
# | AND (X), (Y)                                                  | ?                | 39     |     1 | 5      | N.....Z. |                                              |
# | AND dp, dp                                                    | ?                | 29     |     3 | 6      | N.....Z. |                                              |
# | AND dp, #imm                                                  | ?                | 38     |     3 | 5      | N.....Z. |                                              |
# | OR A, #imm                                                    | ORA #imm         | 8      |     2 | 2      | N.....Z. |                                              |
# | OR A, (X)                                                     | ?                | 6      |     1 | 3      | N.....Z. |                                              |
# | OR A, dp                                                      | ORA dp           | 4      |     2 | 3      | N.....Z. |                                              |
# | OR A, dp+X                                                    | ORA dp, X        | 14     |     2 | 4      | N.....Z. |                                              |
# | OR A, !abs                                                    | ORA abs          | 5      |     3 | 4      | N.....Z. |                                              |
# | OR A, !abs+X                                                  | ORA abs, X       | 15     |     3 | 5      | N.....Z. |                                              |
# | OR A, !abs+Y                                                  | ORA abs, Y       | 16     |     3 | 5      | N.....Z. |                                              |
# | OR A, [dp+X]                                                  | ORA (dp, X)      | 7      |     2 | 6      | N.....Z. |                                              |
# | OR A, [dp]+Y                                                  | ORA (dp), Y      | 17     |     2 | 6      | N.....Z. |                                              |
# | OR (X), (Y)                                                   | ?                | 19     |     1 | 5      | N.....Z. |                                              |
# | OR dp, dp                                                     | ?                | 9      |     3 | 6      | N.....Z. |                                              |
# | OR dp, #imm                                                   | ?                | 18     |     3 | 5      | N.....Z. |                                              |
# | EOR A, #imm                                                   | EOR #imm         | 48     |     2 | 2      | N.....Z. |                                              |
# | EOR A, (X)                                                    | ?                | 46     |     1 | 3      | N.....Z. |                                              |
# | EOR A, dp                                                     | EOR dp           | 44     |     2 | 3      | N.....Z. |                                              |
# | EOR A, dp+X                                                   | EOR dp, X        | 54     |     2 | 4      | N.....Z. |                                              |
# | EOR A, !abs                                                   | EOR abs          | 45     |     3 | 4      | N.....Z. |                                              |
# | EOR A, !abs+X                                                 | EOR abs, X       | 55     |     3 | 5      | N.....Z. |                                              |
# | EOR A, !abs+Y                                                 | EOR abs, Y       | 56     |     3 | 5      | N.....Z. |                                              |
# | EOR A, [dp+X]                                                 | EOR (dp, X)      | 47     |     2 | 6      | N.....Z. |                                              |
# | EOR A, [dp]+Y                                                 | EOR (dp), Y      | 57     |     2 | 6      | N.....Z. |                                              |
# | EOR (X), (Y)                                                  | ?                | 59     |     1 | 5      | N.....Z. |                                              |
# | EOR dp, dp                                                    | ?                | 49     |     3 | 6      | N.....Z. |                                              |
# | EOR dp, #imm                                                  | ?                | 58     |     3 | 5      | N.....Z. |                                              |
# | . 8-bit increment / decrement                                 |                  |        |       |        |          |                                              |
# | INC A                                                         | INC              | BC     |     1 | 2      | N.....Z. |                                              |
# | INC dp                                                        | INC dp           | AB     |     2 | 4      | N.....Z. |                                              |
# | INC dp+X                                                      | INC dp, X        | BB     |     2 | 5      | N.....Z. |                                              |
# | INC !abs                                                      | INC abs          | AC     |     3 | 5      | N.....Z. |                                              |
# | INC X                                                         | INX              | 3D     |     1 | 2      | N.....Z. |                                              |
# | INC Y                                                         | INY              | FC     |     1 | 2      | N.....Z. |                                              |
# | DEC A                                                         | DEC              | 9C     |     1 | 2      | N.....Z. |                                              |
# | DEC dp                                                        | DEC dp           | 8B     |     2 | 4      | N.....Z. |                                              |
# | DEC dp+X                                                      | DEC dp, X        | 9B     |     2 | 5      | N.....Z. |                                              |
# | DEC !abs                                                      | DEC abs          | 8C     |     3 | 5      | N.....Z. |                                              |
# | DEC X                                                         | DEX              | 1D     |     1 | 2      | N.....Z. |                                              |
# | DEC Y                                                         | DEY              | DC     |     1 | 2      | N.....Z. |                                              |
# | . 8-bit shift / rotation                                      |                  |        |       |        |          |                                              |
# | ASL A                                                         | ASL              | 1C     |     1 | 2      | N.....ZC |                                              |
# | ASL dp                                                        | ASL dp           | 0B     |     2 | 4      | N.....ZC |                                              |
# | ASL dp+X                                                      | ASL dp, X        | 1B     |     2 | 5      | N.....ZC |                                              |
# | ASL !abs                                                      | ASL abs          | 0C     |     3 | 5      | N.....ZC |                                              |
# | LSR A                                                         | LSR              | 5C     |     1 | 2      | N.....ZC |                                              |
# | LSR dp                                                        | LSR dp           | 4B     |     2 | 4      | N.....ZC |                                              |
# | LSR dp+X                                                      | LSR dp, X        | 5B     |     2 | 5      | N.....ZC |                                              |
# | LSR !abs                                                      | LSR abs          | 4C     |     3 | 5      | N.....ZC |                                              |
# | ROL A                                                         | ROL              | 3C     |     1 | 2      | N.....ZC |                                              |
# | ROL dp                                                        | ROL dp           | 2B     |     2 | 4      | N.....ZC |                                              |
# | ROL dp+X                                                      | ROL dp, X        | 3B     |     2 | 5      | N.....ZC |                                              |
# | ROL !abs                                                      | ROL abs          | 2C     |     3 | 5      | N.....ZC |                                              |
# | ROR A                                                         | ROR              | 7C     |     1 | 2      | N.....ZC |                                              |
# | ROR dp                                                        | ROR dp           | 6B     |     2 | 4      | N.....ZC |                                              |
# | ROR dp+X                                                      | ROR dp, X        | 7B     |     2 | 5      | N.....ZC |                                              |
# | ROR !abs                                                      | ROR abs          | 6C     |     3 | 5      | N.....ZC |                                              |
# | XCN A                                                         | ?                | 9F     |     1 | 5      | N.....Z. | Exchange nibbles of A                        |
# | . 16-bit operations                                           |                  |        |       |        |          |                                              |
# | MOVW YA, dp                                                   | ?                | BA     |     2 | 5      | N.....Z. |                                              |
# | MOVW dp, YA                                                   | ?                | DA     |     2 | 4      | ........ |                                              |
# | INCW dp                                                       | ?                | 3A     |     2 | 6      | N.....Z. |                                              |
# | DECW dp                                                       | ?                | 1A     |     2 | 6      | N.....Z. |                                              |
# | ADDW YA, dp                                                   | ?                | 7A     |     2 | 5      | NV..H.ZC | Uses carry flag                              |
# | SUBW YA, dp                                                   | ?                | 9A     |     2 | 5      | NV..H.ZC | Uses carry flag                              |
# | CMPW YA, dp                                                   | ?                | 5A     |     2 | 4      | N.....ZC |                                              |
# | MUL YA                                                        | ?                | CF     |     1 | 9      | N.....Z. | "YA = Y * A                                  |
# | n/z flags based on Y register (high-byte) only"               |                  |        |       |        |          |                                              |
# | DIV YA, X                                                     | ?                | 9E     |     1 | 12     | NV..H.Z. | "A = YA / X, Y = YA % X                      |
# | Bit 8 of quotient is stored in the overflow (v) flag.         |                  |        |       |        |          |                                              |
# | Output only valid if quotient is <= 511.                      |                  |        |       |        |          |                                              |
# | n/z flags based on A register (bits 0-7 of quotient) only."   |                  |        |       |        |          |                                              |
# | . decimal adjust                                              |                  |        |       |        |          |                                              |
# | DAA A                                                         | ?                | DF     |     1 | 3      | N.....ZC | Apply carry/half-carry after BCD addition    |
# | DAS A                                                         | ?                | BE     |     1 | 3      | N.....ZC | Apply carry/half-carry after BCD subtraction |
# | . branching                                                   |                  |        |       |        |          |                                              |
# | BRA rel                                                       | BRA rel          | 2F     |     2 | 4      | ........ | Branch always                                |
# | BEQ rel                                                       | BEQ rel          | F0     |     2 | 2/4    | ........ | Branch if Z=1                                |
# | BNE rel                                                       | BNE rel          | D0     |     2 | 2/4    | ........ | Branch if Z=0                                |
# | BCS rel                                                       | BCS rel          | B0     |     2 | 2/4    | ........ | Branch if C=1                                |
# | BCC rel                                                       | BCC rel          | 90     |     2 | 2/4    | ........ | Branch if C=0                                |
# | BVS rel                                                       | BVS rel          | 70     |     2 | 2/4    | ........ | Branch if V=1                                |
# | BVC rel                                                       | BVC rel          | 50     |     2 | 2/4    | ........ | Branch if V=0                                |
# | BMI rel                                                       | BMI rel          | 30     |     2 | 2/4    | ........ | Branch if N=1                                |
# | BPL rel                                                       | BPL rel          | 10     |     2 | 2/4    | ........ | Branch if N=0                                |
# | BBS dp, bit, rel                                              | BBS bit, dp, rel | x3     |     3 | 5/7    | ........ | Branch if dp bit=1, x=(bit*2)                |
# | BBC dp, bit, rel                                              | BBR bit, dp, rel | y3     |     3 | 5/7    | ........ | Branch if dp bit=1, y=(bit*2)+1              |
# | CBNE dp, rel                                                  | ?                | 2E     |     3 | 5/7    | ........ | CMP A, dp then BNE                           |
# | CBNE dp+X, rel                                                | ?                | DE     |     3 | 6/8    | ........ | CMP A, dp+X then BNE                         |
# | DBNZ dp, rel                                                  | ?                | 6E     |     3 | 5/7    | ........ | DEC dp then BNE                              |
# | DBNZ Y, rel                                                   | ?                | FE     |     2 | 4/6    | ........ | DEC Y then BNE                               |
# | JMP !abs                                                      | JMP abs          | 5F     |     3 | 3      | ........ |                                              |
# | JMP [!abs+X]                                                  | JMP (abs, X)     | 1F     |     3 | 6      | ........ |                                              |
# | . subroutines                                                 |                  |        |       |        |          |                                              |
# | CALL !abs                                                     | JSR abs          | 3F     |     3 | 8      | ........ |                                              |
# | PCALL up                                                      | ?                | 4F     |     2 | 6      | ........ | CALL $FF00 + up                              |
# | TCALL n                                                       | ?                | n1     |     1 | 8      | ........ | CALL [$FFDE-(2*n)]                           |
# | BRK                                                           | BRK              | 0F     |     1 | 8      | ...1.0.. |                                              |
# | RET                                                           | RTS              | 6F     |     1 | 5      | ........ |                                              |
# | RETI                                                          | RTI              | 7F     |     1 | 6      | NVPBHIZC |                                              |
# | . stack                                                       |                  |        |       |        |          |                                              |
# | PUSH A                                                        | PHA              | 2D     |     1 | 4      | ........ |                                              |
# | PUSH X                                                        | PHX              | 4D     |     1 | 4      | ........ |                                              |
# | PUSH Y                                                        | PHY              | 6D     |     1 | 4      | ........ |                                              |
# | PUSH PSW                                                      | PHP              | 0D     |     1 | 4      | ........ |                                              |
# | POP A                                                         | PLA              | AE     |     1 | 4      | ........ |                                              |
# | POP X                                                         | PLX              | CE     |     1 | 4      | ........ |                                              |
# | POP Y                                                         | PLY              | EE     |     1 | 4      | ........ |                                              |
# | POP PSW                                                       | PLP              | 8E     |     1 | 4      | NVPBHIZC |                                              |
# | . memory bit operations                                       |                  |        |       |        |          |                                              |
# | SET1 dp, bit                                                  | SMB bit, dp      | x2     |     2 | 4      | ........ | Set dp bit, x=(bit*2)                        |
# | CLR1 dp, bit                                                  | RMB bit, dp      | y2     |     2 | 4      | ........ | Set dp bit, y=(bit*2)+1                      |
# | TSET1 !abs                                                    | TSB abs          | 0E     |     3 | 6      | N.....Z. | "Test and set bits with A                    |
# | Equality test (A - old_value)"                                |                  |        |       |        |          |                                              |
# | TCLR1 !abs                                                    | TRB abs          | 4E     |     3 | 6      | N.....Z. | "Test and clear bits with A                  |
# | Equality test (A - old_value)"                                |                  |        |       |        |          |                                              |
# | AND1 C, abs, bit                                              | ?                | 4A     |     3 | 4      | .......C | C &= [abs] bit                               |
# | AND1 C, /abs, bit                                             | ?                | 6A     |     3 | 4      | .......C | C &= !([abs] bit)                            |
# | OR1 C, abs, bit                                               | ?                | 0A     |     3 | 5      | .......C | C |= [abs] bit                               |
# | OR1 C, /abs, bit                                              | ?                | 2A     |     3 | 5      | .......C | C |= !([abs] bit)                            |
# | EOR1 C, abs, bit                                              | ?                | 8A     |     3 | 5      | .......C | C ^= [abs] bit                               |
# | NOT1 abs, bit                                                 | ?                | EA     |     3 | 5      | ........ | [abs] bit ^= 1                               |
# | MOV1 C, abs, bit                                              | ?                | AA     |     3 | 4      | .......C | C = [abs] bit                                |
# | MOV1 abs, bit, C                                              | ?                | CA     |     3 | 6      | ........ | [abs] bit = C                                |
# | . status flags                                                |                  |        |       |        |          |                                              |
# | CLRC                                                          | CLC              | 60     |     1 | 2      | .......0 |                                              |
# | SETC                                                          | SEC              | 80     |     1 | 2      | .......1 |                                              |
# | NOTC                                                          | ?                | ED     |     1 | 3      | .......C | C ^= 1                                       |
# | CLRV                                                          | CLV              | E0     |     1 | 2      | .0..0... | Clears V and H                               |
# | CLRP                                                          | ?                | 20     |     1 | 2      | ..0..... |                                              |
# | SETP                                                          | ?                | 40     |     1 | 2      | ..1..... |                                              |
# | EI                                                            | CLI              | A0     |     1 | 3      | ......1. |                                              |
# | DI                                                            | SEI              | C0     |     1 | 3      | ......0. |                                              |
# | . no-operation and halt                                       |                  |        |       |        |          |                                              |
# | NOP                                                           | NOP              | 0      |     1 | 2      | ........ |                                              |
# | SLEEP                                                         | WAI              | EF     |     1 | 3      | ........ |                                              |
# | STOP                                                          | STP              | FF     |     1 | 2      | ........ |                                              |
# +---------------------------------------------------------------+------------------+--------+-------+--------+----------+----------------------------------------------+

