module Snes
    module CPU
        class WDC65816 < Utils::Singleton
            include Snes::CPU::Instructions::Opcodes

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

                @opcodes_table = Snes::CPU::Instructions::OPCODES::TABLE

                # Accumulator
                # 8 or 16 Bit
                @a = 0

                # X Register
                #
                # Represents the X index register of the CPU.
                # It is used to:
                #   - Reference memory
                #   - Pass data to memory
                #   - Act as a counter in loops
                #
                # The register can be either 8 or 16 bits, depending on the CPU's mode.
                #
                # @return [Integer]
                @x = 0

                # Same above
                @y = 0

                # Program Counter - Holds the memory address of the current CPU instruction
                @pc = 0

                # Stack Pointer - The stack pointer, points to the next available(unused) location on the stack.
                @sp = 0x01FF

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
                @p = 0x14

                # Direct Page - Direct page register, used for direct page addressing modes.
                # Holds the memory bank address of the data the CPU is accessing.
                @dp = 0

                # Data Bank - Data bank register, holds the default bank for memory transfers.
                # 8-bit
                @dbr = 0

                # PBR - Program Bank - Program Bank, holds the bank address of all instruction fetches.
                # 8-bit
                @pbr = 0

                # === Emulation Mode vs Native Mode ===
                #
                # **Emulation Mode (6502-like):**
                # - Registers (A, X, Y) are 8-bit.
                # - 6502 instructions and timing are used.
                # - Memory is limited to 64K.
                # - Stack and addressing modes are 8-bit.
                # - All 6502 instructions are supported (with bug fixes).
                #
                # **Native Mode (65816 16-bit):**
                # - Registers (A, X, Y) are 16-bit.
                # - 16-bit instructions and enhanced addressing modes.
                # - Memory can be accessed up to 16MB.
                # - 16-bit stack and relocatable direct page.
                # - New instructions are available, not in 6502.
                #
                # Switch between modes using the "X" flag in the status register.
                # Start in emulation mode after reset
                @emulation_mode = true

                @cycles = 0
            end

            def fetch_decode_execute
                @cycles = 0
                @pc &= 0xFFFF

                # ToDo: Check this
                # opcode = self.memory.read((self.PBR << 16) +self.PC)
                # # this meean every address > 0xFF will be wrapped. E.g. 0xFF +1 == 0x00
                # # TODO: use BCD sub if D Flag is set


                opcode_data = @opcodes_table[opcode]

                raise NotImplementedError, "Opcode 0x%02X not implemented" % opcode unless opcode_data

                handler = opcode_data.handler
                description = opcode_data.description
                addressing_mode = opcode_data.addressing_mode
                p_flags = opcode_data.p_flags
                bytes_used = opcode_data.bytes_used
                base_cycles = opcode_data.cycles

                puts "Handler: #{handler}"
                puts "Description: #{description}"
                puts "Addressing Mode: #{addressing_mode}"
                puts "P Flags: #{p_flags.to_s(2).rjust(8, '0')}"  # Exibindo os p_flags como binário
                puts "Bytes Used: #{bytes_used}"
                puts "Base Cycles: #{base_cycles}"

                send(handler)

                old_pc = @pc
                increment_pc
                set_cycles(base_cycles, old_pc)
            end

            def set_cycles(base_cycles, old_pc)
                # Checks whether X is 16-bit and if the last opcode fetch crossed a page boundary.
                extra_cycle = is_page_crossing?(old_pc) ? 1 : 0
                @cycles += base_cycles + extra_cycle
            end

            def fetch_byte
                @memory[@pc]
            end

            def emulation_mode?
                @emulation_mode
            end

            def native_mode?
                !@emulation_mode
            end

            def self.debug_format_flags(p)
                format(
                    "N=%d V=%d M=%d X=%d D=%d I=%d Z=%d C=%d",
                    (p >> 7) & 1,
                    (p >> 6) & 1,
                    (p >> 5) & 1,
                    (p >> 4) & 1,
                    (p >> 3) & 1,
                    (p >> 2) & 1,
                    (p >> 1) & 1,
                    p & 1
                )
            end

            def inspect
                "#<CPU A=%02X P=%08b %s>" % [@a, @p, CPU.debug_format_flags(@p)]
            end

            def status_p_flag?(symbol)
                mask = case symbol
                       when :n then 0b1000_0000
                       when :v then 0b0100_0000
                       when :m then 0b0010_0000
                       when :x then 0b0001_0000
                       when :d then 0b0000_1000
                       when :i then 0b0000_0100
                       when :z then 0b0000_0010
                       when :c then 0b0000_0001
                       end
                (@p & mask) != 0
            end

            def set_p_flag(symbol, value)
                mask = { n:0x80, v:0x40, m:0x20, x:0x10, d:0x08, i:0x04, z:0x02, c:0x01 }[symbol]
                if value
                    @p |= mask
                else
                    @p &= ~mask & 0xFF
                end
            end

            def increment_pc(bytes = 1)
                @pc += bytes
                if @pc > 0xFFFF
                    @pc &= 0xFFFF
                    @pb = (@pb + 1) & 0xFF if native_mode?
                end
            end

            def full_pc
                (@pb << 16) | @pc
            end

            # Instructions That Could Cross Page Boundaries:
            #
            # Any instruction that changes the PC can potentially cross a page boundary, including:
            #
            # - Branching Instructions: Instructions like BEQ, BNE, BCC, BCS, BPL, BMI, BVC, and BVS
            #   that cause a relative jump. These are more likely to cross a page boundary because they
            #   often involve changing the PC by a small signed offset (e.g., 1 byte).
            #
            # - Load/Store Instructions: Instructions that involve loading or storing data (e.g., LDA, STA,
            #   LDX, STX, etc.) could also cause a page boundary crossing if the memory addresses involved
            #   span across two pages.
            #
            # - Increment/Decrement Instructions: Instructions like INX, INY, DEX, DEY, etc., could also
            #   result in page boundary crossing if the increment or decrement changes the PC in such a way.
            def is_page_crossing?(old_pc)
                native_mode? && ((old_pc & 0xFF00) != (@pc & 0xFF00))
            end
        end
    end
end