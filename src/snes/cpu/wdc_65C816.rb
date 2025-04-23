module Snes
    module CPU
        class WDC_65C816 < Utils::Singleton
            include Snes::CPU::Instructions::DataMovement
            include Snes::CPU::Instructions::FlowOfControl
            include Snes::CPU::Instructions::Arithmetic
            include Snes::CPU::Instructions::Logical
            include Snes::CPU::Instructions::BitManipulation
            include Snes::CPU::Instructions::SubroutineCalls
            include Snes::CPU::Instructions::SystemControl

            # # Singleton stuff
            # @instance = new
            # private_class_method :new
            # def self.instance; @instance end

            attr_accessor :a, :x, :y, :pc, :sp, :p, :dp, :dbr, :pbr

            def initialize(memory)
                @memory = memory

                @opcodes_table = Snes::CPU::Instructions::OPCODES_TABLE

                # Accumulator
                # 8 or 16 Bit
                @a = 0

                # Index - The index registers.
                # These can be used to reference memory, to pass data to memory, or as counters for loops.
                # 8 or 16 Bit
                @x = 0

                # Same above
                @y = 0

                # Program Counter - Holds the memory address of the current CPU instruction
                @pc = 0

                # Stack Pointer - The stack pointer, points to the next available(unused) location on the stack.
                @sp = 0

                # Processor Status - Holds various important flags, results of tests and 65816 processing states.
                # Flags stored in P Register
                # Mnemonic 	Value 	Binary Value 	Description
                # N 	    #$80 	10000000 	Negative
                # V 	    #$40 	01000000 	Overflow
                # M 	    #$20 	00100000 	Accumulator register size (native mode only), (0 = 16-bit, 1 = 8-bit)
                # X 	    #$10 	00010000 	Index register size (native mode only), (0 = 16-bit, 1 = 8-bit)
                # D 	    #$08 	00001000 	Decimal
                # I 	    #$04 	00000100 	IRQ disable
                # Z 	    #$02 	00000010 	Zero
                # C 	    #$01 	00000001 	Carry
                # E 			                6502 emulation mode
                # B 	    #$10 	00010000 	Break (emulation mode only)
                @p = 0

                # Direct Page - Direct page register, used for direct page addressing modes.
                # Holds the memory bank address of the data the CPU is accessing.
                @dp = 0

                # Data Bank - Data bank register, holds the default bank for memory transfers.
                # 8-bit
                @dbr = 0

                # PBR - Program Bank - Program Bank, holds the bank address of all instruction fetches.
                # 8-bit
                @pbr = 0
            end

            def fetch_decode_execute
                @pc &= 0xFFFF
                opcode = ''
                handler = @opcodes_table[opcode]
                if handler
                    handler.call
                else
                    raise NotImplementedError, "Opcode 0x%02X not implemented" % opcode
                end
            end
        end
    end
end