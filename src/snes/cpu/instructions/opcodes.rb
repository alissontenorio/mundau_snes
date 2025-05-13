require_relative 'addressing_modes'
require_relative 'impl/arithmetic'
require_relative 'impl/bit_manipulation'
require_relative 'impl/data_movement'
require_relative 'impl/control_flow'
require_relative 'impl/logical'
require_relative 'impl/subroutine_calls'
require_relative 'impl/system_control'

# It has 92 instructions - https://wiki.superfamicom.org/65816-reference

# The size of instructions can vary between 1 byte (8 bits) and 4 bytes (32 bits)
# depending on how memory addresses are referenced (a.k.a the ‘addressing mode’ used)
#
# Instructions are a breakdown of machine code.
# For the SNES, they consist of a 1-byte opcode followed by a 0-3 byte operand.
# Full instructions may be known as words.
# For example, the instruction ADC $3A occupies 2 bytes in memory, and if assembled, it would be stored as E6 3A.
#
# Most instructions that are at least 2 bytes long have more than one addressing mode.
# Addressing modes are put in place so basic instructions may be interpreted correctly given a wide range of operand


module Snes::CPU::Instructions
    module Opcodes
        # p_flags -> nvmx_dizc

        # Opcode = Struct.new(:handler, :description, :addressing_mode, :p_flags, :bytes_used, :cycles) do
        #     def inspect
        #         "#<Opcode handler=#{handler.inspect} description=#{description.inspect} addressing_mode=#{addressing_mode.inspect} p_flags=#{p_flags.inspect} bytes_used=#{bytes_used.inspect} cycles=#{cycles.inspect}>"
        #     end
        # end

        class Opcode
            attr_accessor :handler, :description, :addressing_mode, :p_flags, :base_bytes_used, :base_cycles

            def initialize(handler, description, addressing_mode, p_flags, bytes_used, cycles)
                @handler = handler
                @description = description
                @addressing_mode = addressing_mode
                @p_flags = p_flags
                @base_bytes_used = bytes_used # base bytes
                @base_cycles = cycles
            end

            def to_s
                "Opcode handler=\e[34m#{handler.inspect}\e[0m desc=#{description.inspect} mode=#{addressing_mode.inspect} p_flags=#{p_flags.inspect} bytes=#{base_bytes_used.inspect} cycles=#{base_cycles.inspect}"
            end
        end

        TABLE = {
            # System Control
            0x18 => Opcode.new(:clc, 'Clear Carry Flag', AddressingMode::IMPLIED, 0b0000_0001, 1, 2),

            0x78 => Opcode.new(:sei, 'Set Interrupt Disable Flag', AddressingMode::IMPLIED, 0b0000_0100, 1, 2),

            0xE2 => Opcode.new(:sep, 'Set Status Bit', AddressingMode::IMMEDIATE, 0b1111_1111, 2, 3),

            0xC2 => Opcode.new(:rep, 'Reset Status Bit', AddressingMode::IMMEDIATE, 0b1111_1111, 2, 3),

            0x08 => Opcode.new(:php, 'Push Processor Status on Stack', AddressingMode::IMPLIED, 0b0000_0000, 1, 3),


            # Data Movement
            0x48 => Opcode.new(:pha, 'Push Accumulator', AddressingMode::STACK_PUSH, 0b0000_0000, 1, 3),
            0x68 => Opcode.new(:pla, 'Pull Accumulator', AddressingMode::STACK_PULL, 0b1000_0010, 1, 4),

            0xCD => Opcode.new(:cmp_abs, 'Compare Accumulator with Memory', AddressingMode::ABSOLUTE, 0b1000_0011, 3, 4),
            # 0x64 => Opcode.new(:stz_dp, 'Store Zero to Memory', AddressingMode::DIRECT_PAGE, 0b0000_0000, 2, 3),
            0x9C => Opcode.new(:stz_abs, 'Store Zero to Memory', AddressingMode::ABSOLUTE, 0b0000_0000, 3, 4),

            0x8D => Opcode.new(:sta_abs, 'Store Accumulator To Memory', AddressingMode::ABSOLUTE, 0b0000_0000, 3, 4),
            # 0x8F => Opcode.new(:sta_abs_long, 'Store Accumulator To Memory', AddressingMode::ABSOLUTE_LONG, 0b0000_0000, 4, 5),
            0x85 => Opcode.new(:sta_dp, 'Store Accumulator To Memory', AddressingMode::DIRECT_PAGE, 0b0000_0000, 2, 3),
            # 0x92 => Opcode.new(:sta_dp_indirect, 'Store Accumulator To Memory', AddressingMode::DIRECT_PAGE_INDIRECT, 0b0000_0000, 2, 5),
            # 0x87 => Opcode.new(:sta_dp_indirect_long, 'Store Accumulator To Memory', AddressingMode::DIRECT_PAGE_INDIRECT_LONG, 0b0000_0000, 2, 6),
            # 0x9D => Opcode.new(:sta_abs_x, 'Store Accumulator To Memory', AddressingMode::ABSOLUTE_INDEXED_X, 0b0000_0000, 3, 5),
            # 0x9F => Opcode.new(:sta_abs_long_x, 'Store Accumulator To Memory', AddressingMode::ABSOLUTE_LONG_INDEXED_X, 0b0000_0000, 4, 5),
            # 0x99 => Opcode.new(:sta_abs_y, 'Store Accumulator To Memory', AddressingMode::ABSOLUTE_INDEXED_Y, 0b0000_0000, 3, 5),
            # 0x95 => Opcode.new(:sta_dp_x, 'Store Accumulator To Memory', AddressingMode::DIRECT_PAGE_INDEXED_X, 0b0000_0000, 2, 4),
            # 0x81 => Opcode.new(:sta_dp_indirect_x, 'Store Accumulator To Memory', AddressingMode::DIRECT_PAGE_INDEXED_INDIRECT_X, 0b0000_0000, 2, 6),
            # 0x91 => Opcode.new(:sta_dp_indirect_y, 'Store Accumulator To Memory', AddressingMode::DIRECT_PAGE_INDIRECT_INDEXED_Y, 0b0000_0000, 2, 6),
            # 0x97 => Opcode.new(:sta_dp_indirect_long_y, 'Store Accumulator To Memory', AddressingMode::DIRECT_PAGE_INDIRECT_LONG_INDEXED_Y, 0b0000_0000, 2, 6),
            # 0x83 => Opcode.new(:sta_sr, 'Store Accumulator To Memory', AddressingMode::STACK_RELATIVE, 0b0000_0000, 2, 4),
            # 0x93 => Opcode.new(:sta_sr_indirect_y, 'Store Accumulator To Memory', AddressingMode::STACK_RELATIVE_INDIRECT_INDEXED_Y, 0b0000_0000, 2, 7),

            0xA9 => Opcode.new(:lda_imm, 'Load Accumulator from Memory', AddressingMode::IMMEDIATE, 0b1000_0010, 2, 2),
            # 0xAD => Opcode.new(:lda_abs, 'Load Accumulator from Memory', AddressingMode::ABSOLUTE, 0b1000_0010, 3, 4),
            # 0xAF => Opcode.new(:lda_abs_long, 'Load Accumulator from Memory', AddressingMode::ABSOLUTE_LONG, 0b1000_0010, 4, 5),
            # 0xA5 => Opcode.new(:lda_dp, 'Load Accumulator from Memory', AddressingMode::DIRECT_PAGE, 0b1000_0010, 2, 3),
            # 0xB2 => Opcode.new(:lda_dp_indirect, 'Load Accumulator from Memory', AddressingMode::DIRECT_PAGE_INDIRECT, 0b1000_0010, 2, 5),
            # 0xA7 => Opcode.new(:lda_dp_indirect_long, 'Load Accumulator from Memory', AddressingMode::DIRECT_PAGE_INDIRECT_LONG, 0b1000_0010, 2, 6),
            # 0xBD => Opcode.new(:lda_abs_x, 'Load Accumulator from Memory', AddressingMode::ABSOLUTE_INDEXED_X, 0b1000_0010, 3, 4),
            # 0xBF => Opcode.new(:lda_abs_long_x, 'Load Accumulator from Memory', AddressingMode::ABSOLUTE_LONG_INDEXED_X, 0b1000_0010, 4, 5),
            # 0xB9 => Opcode.new(:lda_abs_y, 'Load Accumulator from Memory', AddressingMode::ABSOLUTE_INDEXED_Y, 0b1000_0010, 3, 4),
            # 0xB5 => Opcode.new(:lda_dp_x, 'Load Accumulator from Memory', AddressingMode::DIRECT_PAGE_INDEXED_X, 0b1000_0010, 2, 4),
            # 0xA1 => Opcode.new(:lda_dp_indirect_x, 'Load Accumulator from Memory', AddressingMode::DIRECT_PAGE_INDEXED_INDIRECT_X, 0b1000_0010, 2, 6),
            # 0xB1 => Opcode.new(:lda_dp_indirect_y, 'Load Accumulator from Memory', AddressingMode::DIRECT_PAGE_INDIRECT_INDEXED_Y, 0b1000_0010, 2, 5),
            0xB7 => Opcode.new(:lda_dp_indirect_long_y, 'Load Accumulator from Memory', AddressingMode::DIRECT_PAGE_INDIRECT_LONG_INDEXED_Y, 0b1000_0010, 2, 6),
            # 0xA3 => Opcode.new(:lda_sr, 'Load Accumulator from Memory', AddressingMode::STACK_RELATIVE, 0b1000_0010, 2, 4),
            # 0xB3 => Opcode.new(:lda_sr_indirect_y, 'Load Accumulator from Memory', AddressingMode::STACK_RELATIVE_INDIRECT_INDEXED_Y, 0b1000_0010, 2, 7),

            0xA0 => Opcode.new(:ldy_imm, 'Load Index Register Y from Memory', AddressingMode::IMMEDIATE, 0b1000_0010, 2, 2),

            0xFB => Opcode.new(:xce, 'Exchange Carry and Emulation Bits', AddressingMode::IMPLIED, 0b0011_0011, 1, 2),

            0x5B => Opcode.new(:tcd, 'Transfer 16-Bit Accumulator to Direct Page Register', AddressingMode::IMPLIED, 0b1000_0010, 1, 2),
            0x1B => Opcode.new(:tcs, 'Transfer Accumulator to Stack Pointer', AddressingMode::IMPLIED, 0b1000_0010, 1, 2),
            0xAA => Opcode.new(:tax, 'Transfer Accumulator to Index Register X', AddressingMode::IMPLIED, 0b1000_0010, 1, 2),
            0xEB => Opcode.new(:xba, 'Exchange B and A 8-bit Accumulators', AddressingMode::IMPLIED, 0b1000_0010, 1, 3),

            # Arithmetic
            0x69 => Opcode.new(:adc_imm, 'Add With Carry', AddressingMode::IMMEDIATE, 0b1100_0011, 2, 2),

            # 0xE8 => Opcode.new(:inx, 'Increment Index Register X', AddressingMode::IMPLIED, 0b1000_0010, 1, 2),
            0xC8 => Opcode.new(:iny, 'Increment Index Register Y', AddressingMode::IMPLIED, 0b1000_0010, 1, 2),

            0xE0 => Opcode.new(:cpx_imm, 'Compare Index Register X with Memory', AddressingMode::IMMEDIATE, 0b1000_0011, 2, 2),


            # Subroutine Calls
            0x20 => Opcode.new(:jsr_abs, 'Jump to Subroutine', AddressingMode::ABSOLUTE, 0b0000_0000, 3, 6),


            # Control Flow
            0xD0 => Opcode.new(:bne, 'Branch if Not Equal', AddressingMode::PROGRAM_COUNTER_RELATIVE, 0b0000_0000, 2, 2),

            0x80 => Opcode.new(:bra, 'Branch Always', AddressingMode::PROGRAM_COUNTER_RELATIVE, 0b0000_0000, 2, 3),

            0x00 => Opcode.new(:brk, 'Software Break', AddressingMode::STACK_INTERRUPT, 0b0001_1100, 2, 7),

            0x70 => Opcode.new(:bvs, 'Branch if Overflow Set', AddressingMode::PROGRAM_COUNTER_RELATIVE, 0b0000_0000, 2, 2),


            # Bit Manipulation
            0x2A => Opcode.new(:rol_a, 'Rotate Memory or Accumulator Left', AddressingMode::ACCUMULATOR, 0b1000_0011, 1, 2),
            # 0x76 => Opcode.new(:ror_dp_x, 'Rotate Memory or Accumulator Right ', AddressingMode::DIRECT_PAGE_INDEXED_X, 0b1000_0011, 2, 6),
        }
    end
end

# Assembler Example 	Alias 	Proper Name 	                                        HEX 	Addressing Mode 	            Flags Set 	Bytes 	Cycles
# ADC (dp,X) 		            Add With Carry 	                                        61 	    DP Indexed Indirect,X 	        NV----ZC 	2 	    6
# ADC sr,S 		                Add With Carry 	                                        63 	    Stack Relative 	                NV----ZC 	2 	    4
# ADC dp 		                Add With Carry 	                                        65 	    Direct Page 	                NV----ZC 	2 	    3
# ADC [dp] 		                Add With Carry 	                                        67 	    DP Indirect Long 	            NV----ZC 	2 	    6
# ADC #const 		            Add With Carry 	                                        69 	    Immediate 	                    NV----ZC 	2 	    2
# ADC addr 		                Add With Carry 	                                        6D 	    Absolute 	                    NV----ZC 	3 	    4
# ADC long 		                Add With Carry 	                                        6F 	    Absolute Long 	                NV----ZC 	4 	    5
# ADC ( dp),Y 		            Add With Carry 	                                        71 	    DP Indirect Indexed, Y 	        NV----ZC 	2 	    5
# ADC (dp) 		                Add With Carry 	                                        72 	    DP Indirect 	                NV----ZC 	2 	    5
# ADC (sr,S),Y 		            Add With Carry 	                                        73 	    SR Indirect Indexed,Y 	        NV----ZC 	2 	    7
# ADC dp,X 		                Add With Carry 	                                        75 	    DP Indexed,X 	                NV----ZC 	2 	    4
# ADC [dp],Y 		            Add With Carry 	                                        77 	    DP Indirect Long Indexed, Y 	NV----ZC 	2 	    6
# ADC addr,Y 		            Add With Carry 	                                        79 	    Absolute Indexed,Y 	            NV----ZC 	3 	    4
# ADC addr,X 		            Add With Carry 	                                        7D 	    Absolute Indexed,X 	            NV----ZC 	3 	    4
# ADC long,X 		            Add With Carry 	                                        7F 	    Absolute Long Indexed,X 	    NV----ZC 	4 	    5
# AND (dp,X) 		            AND Accumulator with Memory 	                        21 	    DP Indexed Indirect,X 	        N-----Z- 	2 	    6
# AND sr,S 		                AND Accumulator with Memory 	                        23 	    Stack Relative 	                N-----Z- 	2 	    4
# AND dp 		                AND Accumulator with Memory 	                        25 	    Direct Page 	                N-----Z- 	2 	    3
# AND [dp] 		                AND Accumulator with Memory 	                        27 	    DP Indirect Long 	            N-----Z- 	2 	    6
# AND #const 		            AND Accumulator with Memory 	                        29 	    Immediate 	                    N-----Z- 	2 	    2
# AND addr 		                AND Accumulator with Memory 	                        2D 	    Absolute 	                    N-----Z- 	3 	    4
# AND long 		                AND Accumulator with Memory 	                        2F 	    Absolute Long 	                N-----Z- 	4 	    5
# AND (dp),Y 		            AND Accumulator with Memory 	                        31 	    DP Indirect Indexed, Y 	        N-----Z- 	2 	    5
# AND (dp) 		                AND Accumulator with Memory 	                        32 	    DP Indirect 	                N-----Z- 	2 	    5
# AND (sr,S),Y 		            AND Accumulator with Memory 	                        33 	    SR Indirect Indexed,Y 	        N-----Z- 	2 	    7
# AND dp,X 		                AND Accumulator with Memory 	                        35 	    DP Indexed,X 	                N-----Z- 	2 	    4
# AND [dp],Y 		            AND Accumulator with Memory 	                        37 	    DP Indirect Long Indexed, Y 	N-----Z- 	2 	    6
# AND addr,Y 		            AND Accumulator with Memory 	                        39 	    Absolute Indexed,Y 	            N-----Z- 	3 	    4
# AND addr,X 		            AND Accumulator with Memory 	                        3D 	    Absolute Indexed,X 	            N-----Z- 	3 	    4
# AND long,X 		            AND Accumulator with Memory 	                        3F 	    Absolute Long Indexed,X 	    N-----Z- 	4 	    5
# ASL dp 		                Arithmetic Shift Left 	                                06 	    Direct Page 	                N-----ZC 	2 	    5
# ASL A 		                Arithmetic Shift Left 	                                0A 	    Accumulator 	                N-----ZC 	1 	    2
# ASL addr 		                Arithmetic Shift Left 	                                0E 	    Absolute 	                    N-----ZC 	3 	    6
# ASL dp,X 		                Arithmetic Shift Left 	                                16 	    DP Indexed,X 	                N-----ZC 	2 	    6
# ASL addr,X 		            Arithmetic Shift Left 	                                1E 	    Absolute Indexed,X 	            N-----ZC 	3 	    7
# BCC nearlabel 	       BLT 	Branch if Carry Clear 	                                90 	    Program Counter Relative 		            2 	    2
# BCS nearlabel 	       BGE 	Branch if Carry Set 	                                B0 	    Program Counter Relative 		            2 	    2
# BEQ nearlabel 		        Branch if Equal 	                                    F0 	    Program Counter Relative 		            2 	    2
# BIT dp 		                Test Bits 	                                            24 	    Direct Page 	                NV----Z- 	2 	    3
# BIT addr 		                Test Bits 	                                            2C 	    Absolute 	                    NV----Z- 	3 	    4
# BIT dp,X 		                Test Bits 	                                            34 	    DP Indexed,X 	                NV----Z- 	2 	    4
# BIT addr,X 		            Test Bits 	                                            3C 	    Absolute Indexed,X 	            NV----Z- 	3 	    4
# BIT #const 		            Test Bits 	                                            89 	    Immediate 	                    ------Z- 	2 	    2
# BMI nearlabel 		        Branch if Minus 	                                    30 	    Program Counter Relative 		            2 	    2
# BNE nearlabel 		        Branch if Not Equal 	                                D0 	    Program Counter Relative 		            2 	    2
# BPL nearlabel 		        Branch if Plus 	                                        10 	    Program Counter Relative 		            2 	    2
# BRA nearlabel 		        Branch Always 	                                        80 	    Program Counter Relative 		            2 	    3
# BRK 		                    Break 	                                                00 	    Stack/Interrupt 	            ----DI-- 	2 	    7
# BRL label 		            Branch Long Always 	                                    82 	    Program Counter Relative Long 		        3 	    4
# BVC nearlabel 		        Branch if Overflow Clear 	                            50 	    Program Counter Relative 		            2 	    2
# BVS nearlabel 		        Branch if Overflow Set 	                                70 	    Program Counter Relative 		            2 	    2
# CLC 		                    Clear Carry 	                                        18 	    Implied 	                    -------C 	1 	    2
# CLD 		                    Clear Decimal Mode Flag 	                            D8 	    Implied 	                    ----D--- 	1 	    2
# CLI 		                    Clear Interrupt Disable Flag 	                        58 	    Implied 	                    -----I-- 	1 	    2
# CLV 		                    Clear Overflow Flag 	                                B8 	    Implied 	                    -V------ 	1 	    2
# CMP (dp,X) 		            Compare Accumulator with Memory 	                    C1 	    DP Indexed Indirect,X 	        N-----ZC 	2 	    6
# CMP sr,S 		                Compare Accumulator with Memory 	                    C3 	    Stack Relative 	                N-----ZC 	2 	    4
# CMP dp 		                Compare Accumulator with Memory 	                    C5 	    Direct Page 	                N-----ZC 	2 	    3
# CMP [dp] 		                Compare Accumulator with Memory 	                    C7 	    DP Indirect Long 	            N-----ZC 	2 	    6
# CMP #const 		            Compare Accumulator with Memory 	                    C9 	    Immediate 	                    N-----ZC 	2 	    2
# CMP addr 		                Compare Accumulator with Memory 	                    CD 	    Absolute 	                    N-----ZC 	3 	    4
# CMP long 		                Compare Accumulator with Memory 	                    CF 	    Absolute Long 	                N-----ZC 	4 	    5
# CMP (dp),Y 		            Compare Accumulator with Memory 	                    D1 	    DP Indirect Indexed, Y 	        N-----ZC 	2 	    5
# CMP (dp) 		                Compare Accumulator with Memory 	                    D2 	    DP Indirect 	                N-----ZC 	2 	    5
# CMP (sr,S),Y 		            Compare Accumulator with Memory 	                    D3 	    SR Indirect Indexed,Y 	        N-----ZC 	2 	    7
# CMP dp,X 		                Compare Accumulator with Memory 	                    D5 	    DP Indexed,X 	                N-----ZC 	2 	    4
# CMP [dp],Y 		            Compare Accumulator with Memory 	                    D7 	    DP Indirect Long Indexed, Y 	N-----ZC 	2 	    6
# CMP addr,Y 		            Compare Accumulator with Memory 	                    D9 	    Absolute Indexed,Y 	            N-----ZC 	3 	    4
# CMP addr,X 		            Compare Accumulator with Memory 	                    DD 	    Absolute Indexed,X 	            N-----ZC 	3 	    4
# CMP long,X 		            Compare Accumulator with Memory 	                    DF 	    Absolute Long Indexed,X 	    N-----ZC 	4 	    5
# COP #const 		            Co-Processor 	                                        02 	    Stack/Interrupt 	            ----DI-- 	2 	    7
# CPX #const 		            Compare Index Register X with Memory 	                E0 	    Immediate 	                    N-----ZC 	2 	    2
# CPX dp 		                Compare Index Register X with Memory 	                E4 	    Direct Page 	                N-----ZC 	2 	    3
# CPX addr 		                Compare Index Register X with Memory 	                EC 	    Absolute 	                    N-----ZC 	3 	    4
# CPY #const 		            Compare Index Register Y with Memory 	                C0 	    Immediate 	                    N-----ZC 	2 	    2
# CPY dp 		                Compare Index Register Y with Memory 	                C4 	    Direct Page 	                N-----ZC 	2 	    3
# CPY addr 		                Compare Index Register Y with Memory 	                CC 	    Absolute 	                    N-----ZC 	3 	    4
# DEC A 	            DEA 	Decrement 	                                            3A 	    Accumulator 	                N-----Z- 	1 	    2
# DEC dp 		                Decrement 	                                            C6 	    Direct Page 	                N-----Z- 	2 	    5
# DEC addr 		                Decrement 	                                            CE 	    Absolute 	                    N-----Z- 	3 	    6
# DEC dp,X 		                Decrement 	                                            D6 	    DP Indexed,X 	                N-----Z- 	2 	    6
# DEC addr,X 		            Decrement 	                                            DE 	    Absolute Indexed,X 	            N-----Z- 	3 	    7
# DEX 		                    Decrement Index Register X 	                            CA 	    Implied 	                    N-----Z- 	1 	    2
# DEY 		                    Decrement Index Register Y 	                            88 	    Implied 	                    N-----Z- 	1 	    2
# EOR (dp,X) 		            Exclusive-OR Accumulator with Memory 	                41 	    DP Indexed Indirect,X 	        N-----Z- 	2 	    6
# EOR sr,S 		                Exclusive-OR Accumulator with Memory 	                43 	    Stack Relative 	                N-----Z- 	2 	    4
# EOR dp 		                Exclusive-OR Accumulator with Memory 	                45 	    Direct Page 	                N-----Z- 	2 	    3
# EOR [dp] 		                Exclusive-OR Accumulator with Memory 	                47 	    DP Indirect Long 	            N-----Z- 	2 	    6
# EOR #const 		            Exclusive-OR Accumulator with Memory 	                49 	    Immediate 	                    N-----Z- 	2 	    2
# EOR addr 		                Exclusive-OR Accumulator with Memory 	                4D 	    Absolute 	                    N-----Z- 	3 	    4
# EOR long 		                Exclusive-OR Accumulator with Memory 	                4F 	    Absolute Long 	                N-----Z- 	4 	    5
# EOR (dp),Y 		            Exclusive-OR Accumulator with Memory 	                51 	    DP Indirect Indexed, Y 	        N-----Z- 	2 	    5
# EOR (dp) 		                Exclusive-OR Accumulator with Memory 	                52 	    DP Indirect 	                N-----Z- 	2 	    5
# EOR (sr,S),Y 		            Exclusive-OR Accumulator with Memory 	                53 	    SR Indirect Indexed,Y 	        N-----Z- 	2 	    7
# EOR dp,X 		                Exclusive-OR Accumulator with Memory 	                55 	    DP Indexed,X 	                N-----Z- 	2 	    4
# EOR [dp],Y 		            Exclusive-OR Accumulator with Memory 	                57 	    DP Indirect Long Indexed, Y 	N-----Z- 	2 	    6
# EOR addr,Y 		            Exclusive-OR Accumulator with Memory 	                59 	    Absolute Indexed,Y 	            N-----Z- 	3 	    4
# EOR addr,X 		            Exclusive-OR Accumulator with Memory 	                5D 	    Absolute Indexed,X 	            N-----Z- 	3 	    4
# EOR long,X 		            Exclusive-OR Accumulator with Memory 	                5F 	    Absolute Long Indexed,X 	    N-----Z- 	4 	    5
# INC A 	            INA 	Increment 	                                            1A 	    Accumulator 	                N-----Z- 	1 	    2
# INC dp 		                Increment 	                                            E6 	    Direct Page 	                N-----Z- 	2 	    5
# INC addr 		                Increment 	                                            EE 	    Absolute 	                    N-----Z- 	3 	    6
# INC dp,X 		                Increment 	                                            F6 	    DP Indexed,X 	                N-----Z- 	2 	    6
# INC addr,X 		            Increment 	                                            FE 	    Absolute Indexed,X 	            N-----Z- 	3 	    7
# INX 		                    Increment Index Register X 	                            E8 	    Implied 	                    N-----Z- 	1 	    2
# INY 		                    Increment Index Register Y 	                            C8 	    Implied 	                    N-----Z- 	1 	    2
# JMP addr 		                Jump 	                                                4C 	    Absolute 		                            3 	    3
# JMP long 	JML 	            Jump 	                                                5C 	    Absolute Long 		                        4 	    4
# JMP (addr) 		            Jump 	                                                6C 	    Absolute Indirect 		                    3 	    5
# JMP (addr,X) 		            Jump 	                                                7C 	    Absolute Indexed Indirect 		            3 	    6
# JMP [addr] 	           JML 	Jump 	                                                DC 	    Absolute Indirect Long 		                3 	    6
# JSR addr 		                Jump to Subroutine 	                                    20 	    Absolute 		                            3 	    6
# JSR long 	JSL 	            Jump to Subroutine 	                                    22 	    Absolute Long 		                        4 	    8
# JSR (addr,X)) 		        Jump to Subroutine 	                                    FC 	    Absolute Indexed Indirect 		            3 	    8
# LDA (dp,X) 		            Load Accumulator from Memory 	                        A1 	    DP Indexed Indirect,X 	        N-----Z- 	2 	    6
# LDA sr,S 		                Load Accumulator from Memory 	                        A3 	    Stack Relative 	                N-----Z- 	2 	    4
# LDA dp 		                Load Accumulator from Memory 	                        A5 	    Direct Page 	                N-----Z- 	2 	    3
# LDA [dp] 		                Load Accumulator from Memory 	                        A7 	    DP Indirect Long 	            N-----Z- 	2 	    6
# LDA #const 		            Load Accumulator from Memory 	                        A9 	    Immediate 	                    N-----Z- 	2 	    2
# LDA addr 		                Load Accumulator from Memory 	                        AD 	    Absolute 	                    N-----Z- 	3 	    4
# LDA long 		                Load Accumulator from Memory 	                        AF 	    Absolute Long 	                N-----Z- 	4 	    5
# LDA (dp),Y 		            Load Accumulator from Memory 	                        B1 	    DP Indirect Indexed, Y 	        N-----Z- 	2 	    5
# LDA (dp) 		                Load Accumulator from Memory 	                        B2 	    DP Indirect 	                N-----Z- 	2 	    5
# LDA (sr,S),Y 		            Load Accumulator from Memory 	                        B3 	    SR Indirect Indexed,Y 	        N-----Z- 	2 	    7
# LDA dp,X 		                Load Accumulator from Memory 	                        B5 	    DP Indexed,X 	                N-----Z- 	2 	    4
# LDA [dp],Y 		            Load Accumulator from Memory 	                        B7 	    DP Indirect Long Indexed, Y 	N-----Z- 	2 	    6
# LDA addr,Y 		            Load Accumulator from Memory 	                        B9 	    Absolute Indexed,Y 	            N-----Z- 	3 	    4
# LDA addr,X 		            Load Accumulator from Memory 	                        BD 	    Absolute Indexed,X 	            N-----Z- 	3 	    4
# LDA long,X 		            Load Accumulator from Memory 	                        BF 	    Absolute Long Indexed,X 	    N-----Z- 	4 	    5
# LDX #const 		            Load Index Register X from Memory 	                    A2 	    Immediate 	                    N-----Z- 	2 	    2
# LDX dp 		                Load Index Register X from Memory 	                    A6 	    Direct Page 	                N-----Z- 	2 	    3
# LDX addr 		                Load Index Register X from Memory 	                    AE 	    Absolute 	                    N-----Z- 	3 	    4
# LDX dp,Y 		                Load Index Register X from Memory 	                    B6 	    DP Indexed,Y 	                N-----Z- 	2 	    4
# LDX addr,Y 		            Load Index Register X from Memory 	                    BE 	    Absolute Indexed,Y              N-----Z- 	3 	    4
# LDY #const 		            Load Index Register Y from Memory 	                    A0 	    Immediate 	                    N-----Z- 	2 	    2
# LDY dp 		                Load Index Register Y from Memory 	                    A4 	    Direct Page 	                N-----Z- 	2 	    3
# LDY addr 		                Load Index Register Y from Memory 	                    AC 	    Absolute 	                    N-----Z- 	3 	    4
# LDY dp,X 		                Load Index Register Y from Memory 	                    B4 	    DP Indexed,X 	                N-----Z- 	2 	    4
# LDY addr,X 		            Load Index Register Y from Memory 	                    BC 	    Absolute Indexed,X 	            N-----Z- 	3 	    4
# LSR dp 		                Logical Shift Memory or Accumulator Right 	            46 	    Direct Page 	                N-----ZC 	2 	    5
# LSR A 		                Logical Shift Memory or Accumulator Right 	            4A 	    Accumulator 	                N-----ZC 	1 	    2
# LSR addr 		                Logical Shift Memory or Accumulator Right 	            4E 	    Absolute 	                    N-----ZC 	3 	    6
# LSR dp,X 		                Logical Shift Memory or Accumulator Right 	            56 	    DP Indexed,X 	                N-----ZC 	2 	    6
# LSR addr,X 		            Logical Shift Memory or Accumulator Right 	            5E 	    Absolute Indexed,X 	            N-----ZC 	3 	    7
# MVN srcbk,destbk 		        Block Move Negative 	                                54 	    Block Move 		                            3 	    1
# MVP srcbk,destbk 		        Block Move Positive 	                                44 	    Block Move 		                            3 	    1
# NOP 		                    No Operation 	                                        EA 	    Implied 		                            1 	    2
# ORA (dp,X) 		            OR Accumulator with Memory 	                            01 	    DP Indexed Indirect,X 	        N-----Z- 	2 	    6
# ORA sr,S 		                OR Accumulator with Memory 	                            03 	    Stack Relative 	                N-----Z- 	2 	    4
# ORA dp 		                OR Accumulator with Memory 	                            05 	    Direct Page 	                N-----Z- 	2 	    3
# ORA [dp] 		                OR Accumulator with Memory 	                            07 	    DP Indirect Long 	            N-----Z- 	2 	    6
# ORA #const 		            OR Accumulator with Memory 	                            09 	    Immediate 	                    N-----Z- 	2 	    2
# ORA addr 		                OR Accumulator with Memory 	                            0D 	    Absolute 	                    N-----Z- 	3 	    4
# ORA long 		                OR Accumulator with Memory 	                            0F 	    Absolute Long 	                N-----Z- 	4 	    5
# ORA (dp),Y 		            OR Accumulator with Memory 	                            11 	    DP Indirect Indexed, Y 	        N-----Z- 	2 	    5
# ORA (dp) 		                OR Accumulator with Memory 	                            12 	    DP Indirect 	                N-----Z- 	2 	    5
# ORA (sr,S),Y 		            OR Accumulator with Memory 	                            13 	    SR Indirect Indexed,Y 	        N-----Z- 	2 	    7
# ORA dp,X 		                OR Accumulator with Memory 	                            15 	    DP Indexed,X 	                N-----Z- 	2 	    4
# ORA [dp],Y 		            OR Accumulator with Memory 	                            17 	    DP Indirect Long Indexed, Y 	N-----Z- 	2 	    6
# ORA addr,Y 		            OR Accumulator with Memory 	                            19 	    Absolute Indexed,Y 	            N-----Z- 	3 	    4
# ORA addr,X 		            OR Accumulator with Memory 	                            1D 	    Absolute Indexed,X 	            N-----Z- 	3 	    4
# ORA long,X 		            OR Accumulator with Memory 	                            1F 	    Absolute Long Indexed,X 	    N-----Z- 	4 	    5
# PEA addr 		                Push Effective Absolute Address 	                    F4 	    Stack (Absolute) 		                    3 	    5
# PEI (dp) 		                Push Effective Indirect Address 	                    D4 	    Stack (DP Indirect) 		                2 	    6
# PER label 		            Push Effective PC Relative Indirect Address 	        62 	    Stack (PC Relative Long) 		            3 	    6
# PHA 		                    Push Accumulator 	                                    48 	    Stack (Push) 		                        1 	    3
# PHB 		                    Push Data Bank Register 	                            8B 	    Stack (Push) 		                        1 	    3
# PHD 		                    Push Direct Page Register 	                            0B 	    Stack (Push) 		                        1 	    4
# PHK 		                    Push Program Bank Register 	                            4B 	    Stack (Push) 		                        1 	    3
# PHP 		                    Push Processor Status Register 	                        08 	    Stack (Push) 		                        1 	    3
# PHX 		                    Push Index Register X 	                                DA 	    Stack (Push) 		                        1 	    3
# PHY 		                    Push Index Register Y 	                                5A 	    Stack (Push) 		                        1 	    3
# PLA 		                    Pull Accumulator 	                                    68 	    Stack (Pull) 	                N-----Z- 	1 	    4
# PLB 		                    Pull Data Bank Register 	                            AB 	    Stack (Pull) 	                N-----Z- 	1 	    4
# PLD 		                    Pull Direct Page Register 	                            2B 	    Stack (Pull) 	                N-----Z- 	1 	    5
# PLP 		                    Pull Processor Status Register                          28 	    Stack (Pull) 	                NVMXDIZC 	1 	    4
# PLX 		                    Pull Index Register X 	                                FA 	    Stack (Pull) 	                N-----Z- 	1 	    4
# PLY 		                    Pull Index Register Y 	                                7A 	    Stack (Pull) 	                N-----Z- 	1 	    4
# REP #const 		            Reset Processor Status Bits 	                        C2 	    Immediate 	                    NVMXDIZC 	2 	    3
# ROL dp 		                Rotate Memory or Accumulator Left 	                    26 	    Direct Page 	                N-----ZC 	2 	    5
# ROL A 		                Rotate Memory or Accumulator Left 	                    2A 	    Accumulator 	                N-----ZC 	1 	    2
# ROL addr 		                Rotate Memory or Accumulator Left 	                    2E 	    Absolute 	                    N-----ZC 	3 	    6
# ROL dp,X 		                Rotate Memory or Accumulator Left 	                    36 	    DP Indexed,X 	                N-----ZC 	2 	    6
# ROL addr,X 		            Rotate Memory or Accumulator Left 	                    3E 	    Absolute Indexed,X 	            N-----ZC 	3 	    7
# ROR dp 		                Rotate Memory or Accumulator Right 	                    66 	    Direct Page 	                N-----ZC 	2 	    5
# ROR A 		                Rotate Memory or Accumulator Right 	                    6A 	    Accumulator 	                N-----ZC 	1 	    2
# ROR addr 		                Rotate Memory or Accumulator Right 	                    6E 	    Absolute 	                    N-----ZC 	3 	    6
# ROR dp,X 		                Rotate Memory or Accumulator Right 	                    76 	    DP Indexed,X 	                N-----ZC 	2 	    6
# ROR addr,X 		            Rotate Memory or Accumulator Right 	                    7E 	    Absolute Indexed,X 	            N-----ZC 	3 	    7
# RTI 		                    Return from Interrupt 	                                40 	    Stack (RTI) 	                NVMXDIZC 	1 	    6
# RTL 		                    Return from Subroutine Long 	                        6B 	    Stack (RTL) 		                        1 	    6
# RTS 		                    Return from Subroutine 	                                60 	    Stack (RTS) 		                        1 	    6
# SBC (dp,X) 		            Subtract with Borrow from Accumulator 	                E1 	    DP Indexed Indirect,X 	        NV----ZC 	2 	    6
# SBC sr,S 		                Subtract with Borrow from Accumulator 	                E3 	    Stack Relative 	                NV----ZC 	2 	    4
# SBC dp 		                Subtract with Borrow from Accumulator 	                E5 	    Direct Page 	                NV----ZC 	2 	    3
# SBC [dp] 		                Subtract with Borrow from Accumulator 	                E7 	    DP Indirect Long 	            NV----ZC 	2 	    6
# SBC #const 		            Subtract with Borrow from Accumulator 	                E9 	    Immediate 	                    NV----ZC 	2 	    2
# SBC addr 		                Subtract with Borrow from Accumulator 	                ED 	    Absolute 	                    NV----ZC 	3 	    4
# SBC long 		                Subtract with Borrow from Accumulator 	                EF 	    Absolute Long 	                NV----ZC 	4 	    5
# SBC (dp),Y 		            Subtract with Borrow from Accumulator 	                F1 	    DP Indirect Indexed, Y 	        NV----ZC 	2 	    5
# SBC (dp) 		                Subtract with Borrow from Accumulator 	                F2 	    DP Indirect 	                NV----ZC 	2 	    5
# SBC (sr,S),Y 		            Subtract with Borrow from Accumulator 	                F3 	    SR Indirect Indexed,Y 	        NV----ZC 	2 	    7
# SBC dp,X 		                Subtract with Borrow from Accumulator 	                F5 	    DP Indexed,X 	                NV----ZC 	2 	    4
# SBC [dp],Y 		            Subtract with Borrow from Accumulator 	                F7 	    DP Indirect Long Indexed, Y 	NV----ZC 	2 	    6
# SBC addr,Y 		            Subtract with Borrow from Accumulator 	                F9 	    Absolute Indexed,Y 	            NV----ZC 	3 	    4
# SBC addr,X 		            Subtract with Borrow from Accumulator 	                FD 	    Absolute Indexed,X 	            NV----ZC 	3 	    4
# SBC long,X 		            Subtract with Borrow from Accumulator 	                FF 	    Absolute Long Indexed,X 	    NV----ZC 	4 	    5
# SEC 		                    Set Carry Flag 	                                        38 	    Implied 	                    -------C 	1 	    2
# SED 		                    Set Decimal Flag 	                                    F8 	    Implied 	                    ----D--- 	1 	    2
# SEI 		                    Set Interrupt Disable Flag 	                            78 	    Implied 	                    -----I-- 	1 	    2
# SEP #const 		            Set Processor Status Bits 	                            E2 	    Immediate 	                    NVMXDIZC 	2 	    3
# STA (dp,X) 		            Store Accumulator to Memory 	                        81 	    DP Indexed Indirect,X 		                2 	    6
# STA sr,S 		                Store Accumulator to Memory 	                        83 	    Stack Relative 		                        2 	    4
# STA dp 		                Store Accumulator to Memory 	                        85 	    Direct Page 		                        2 	    3
# STA [dp] 		                Store Accumulator to Memory 	                        87 	    DP Indirect Long 		                    2 	    6
# STA addr 		                Store Accumulator to Memory 	                        8D 	    Absolute 		                            3 	    4
# STA long 		                Store Accumulator to Memory 	                        8F 	    Absolute Long 		                        4 	    5
# STA (dp),Y 		            Store Accumulator to Memory 	                        91 	    DP Indirect Indexed, Y 		                2 	    6
# STA (dp) 		                Store Accumulator to Memory 	                        92 	    DP Indirect 		                        2 	    5
# STA (sr,S),Y 		            Store Accumulator to Memory 	                        93 	    SR Indirect Indexed,Y 		                2 	    7
# STA _dp_X 		            Store Accumulator to Memory 	                        95 	    DP Indexed,X 		                        2 	    4
# STA [dp],Y 		            Store Accumulator to Memory 	                        97 	    DP Indirect Long Indexed, Y 		        2 	    6
# STA addr,Y 		            Store Accumulator to Memory 	                        99 	    Absolute Indexed,Y 		                    3 	    5
# STA addr,X 		            Store Accumulator to Memory 	                        9D 	    Absolute Indexed,X 		                    3 	    5
# STA long,X 		            Store Accumulator to Memory 	                        9F 	    Absolute Long Indexed,X 		            4 	    5
# STP 		                    Stop Processor 	                                        DB 	    Implied 		                            1 	    3
# STX dp 		                Store Index Register X to Memory 	                    86 	    Direct Page 		                        2 	    3
# STX addr 		                Store Index Register X to Memory 	                    8E 	    Absolute 		                            3 	    4
# STX dp,Y 		                Store Index Register X to Memory 	                    96 	    DP Indexed,Y 		                        2 	    4
# STY dp 		                Store Index Register Y to Memory 	                    84 	    Direct Page 		                        2 	    3
# STY addr 		                Store Index Register Y to Memory 	                    8C 	    Absolute 		                            3 	    4
# STY dp,X 		                Store Index Register Y to Memory 	                    94 	    DP Indexed,X 		                        2 	    4
# STZ dp 		                Store Zero to Memory 	                                64 	    Direct Page 		                        2 	    3
# STZ dp,X 		                Store Zero to Memory 	                                74 	    DP Indexed,X 		                        2 	    4
# STZ addr 		                Store Zero to Memory 	                                9C 	    Absolute 		                            3 	    4
# STZ addr,X 		            Store Zero to Memory 	                                9E 	    Absolute Indexed,X 		                    3 	    5
# TAX 		                    Transfer Accumulator to Index Register X 	            AA 	    Implied 	                    N-----Z- 	1 	    2
# TAY 		                    Transfer Accumulator to Index Register Y 	            A8 	    Implied 	                    N-----Z- 	1 	    2
# TCD 		                    Transfer 16-bit Accumulator to Direct Page Register 	5B 	    Implied 	                    N-----Z- 	1 	    2
# TCS 		                    Transfer 16-bit Accumulator to Stack Pointer 	        1B 	    Implied 		                            1 	    2
# TDC 		                    Transfer Direct Page Register to 16-bit Accumulator 	7B 	    Implied 	                    N-----Z- 	1 	    2
# TRB dp 		                Test and Reset Memory Bits Against Accumulator 	        14 	    Direct Page 	                ------Z- 	2 	    5
# TRB addr 		                Test and Reset Memory Bits Against Accumulator 	        1C 	    Absolute 	                    ------Z- 	3 	    6
# TSB dp 		                Test and Set Memory Bits Against Accumulator 	        04 	    Direct Page 	                ------Z- 	2 	    5
# TSB addr 		                Test and Set Memory Bits Against Accumulator 	        0C 	    Absolute 	                    ------Z- 	3 	    6
# TSC 		                    Transfer Stack Pointer to 16-bit Accumulator 	        3B 	    Implied 	                    N-----Z- 	1 	    2
# TSX 		                    Transfer Stack Pointer to Index Register X 	            BA 	    Implied 	                    N-----Z- 	1 	    2
# TXA 		                    Transfer Index Register X to Accumulator 	            8A 	    Implied 	                    N-----Z- 	1 	    2
# TXS 		                    Transfer Index Register X to Stack Pointer 	            9A 	    Implied 		                            1 	    2
# TXY 		                    Transfer Index Register X to Index Register Y 	        9B 	    Implied 	                    N-----Z- 	1 	    2
# TYA 		                    Transfer Index Register Y to Accumulator 	            98 	    Implied 	                    N-----Z- 	1 	    2
# TYX 		                    Transfer Index Register Y to Index Register X 	        BB 	    Implied 	                    N-----Z- 	1 	    2
# WAI 		                    Wait for Interrupt 	                                    CB 	    Implied 		                            1 	    3
# WDM 		                    Reserved for Future Expansion 	                        42 	    		                                    2 	    0
# XBA 		                    Exchange B and A 8-bit Accumulators 	                EB 	    Implied 	                    N-----Z- 	1 	    3
# XCE 		                    Exchange Carry and Emulation Flags                      FB 	    Implied 	                    --MX---CE 	1 	    2