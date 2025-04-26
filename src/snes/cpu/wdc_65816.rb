require_relative 'instructions/opcodes'
require_relative 'internal_cpu_registers'

module Snes
    module CPU
        class WDC65816
            include Singleton

            include Snes::CPU::Instructions::Opcodes

            include Snes::CPU::Instructions::DataMovement
            include Snes::CPU::Instructions::FlowOfControl
            include Snes::CPU::Instructions::Arithmetic
            include Snes::CPU::Instructions::Logical
            include Snes::CPU::Instructions::BitManipulation
            include Snes::CPU::Instructions::SubroutineCalls
            include Snes::CPU::Instructions::SystemControl


            InternalCPU_Registers = Snes::CPU::InternalCPURegisters.instance

            # # Singleton stuff
            # @instance = new
            # private_class_method :new
            # def self.instance; @instance end

            attr_accessor :a, :x, :y, :pc, :sp, :p, :dp, :dbr, :pbr, :cycles, :emulation_mode

            def setup(memory, reset_addr, debug=false)
                @debug = debug
                @memory = memory

                @opcodes_table = Snes::CPU::Instructions::Opcodes::TABLE

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
                @pc = reset_addr

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
                @p = 0x34

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

            def disassemble(opcode_data)
                handler = opcode_data.handler
                description = opcode_data.description
                addressing_mode = opcode_data.addressing_mode
                p_flags = opcode_data.p_flags
                base_bytes_used = opcode_data.bytes_used
                base_cycles = opcode_data.cycles

                puts opcode_data

                # puts "Handler: #{handler}"
                # puts "Description: #{description}"
                # puts "Addressing Mode: #{addressing_mode}"
                # puts "P Flags: #{p_flags.to_s(2).rjust(8, '0')}"
                # puts "Bytes Used: #{base_bytes_used}"
                # puts "Base Cycles: #{base_cycles}"
                puts ""
            end

            def get_opcode_addr
                emulation_mode? ? @pc : ((@pbr << 16) + @pc)
            end

            def read_opcode(opcode_addr)
                @memory.access(opcode_addr, :read)
            end

            def get_opcode_data(opcode)
                opcode_data = @opcodes_table[opcode] # 1 cycle for fetching the opcode
                raise NotImplementedError, "Opcode 0x%02X not implemented" % opcode unless opcode_data
                puts opcode_data
                # opcode_something = opcode_data.disassemble
                handler = opcode_data.handler
                $logger.debug("0x#{opcode.to_s(16)} - Operation #{handler}") if @debug
                # $logger.debug("Operation #{handler} : #{@pc.to_s(16)}") if @debug
                base_cycles = opcode_data.cycles
                [handler, base_cycles]
            end

            def fetch_decode_execute
                @cycles = 0     # Clear cycles
                @pc &= 0xFFFF   # If PC exceeeds FFFF

                opcode_addr = get_opcode_addr
                opcode = read_opcode(opcode_addr)
                handler, base_cycles = get_opcode_data(opcode)
                increment_pc! # Because of read_opcode
                @cycles += base_cycles
                result = send(handler) # Call Instruction
            end

            def increment_cycles_if_page_crossing(old_pc)
                # Checks whether X is 16-bit and if the last opcode fetch crossed a page boundary.
                # extra_cycle if necessary
                @cycles += is_page_crossing?(old_pc) ? 1 : 0
            end

            def read_8(address = full_pc)
                @memory.access(address & 0xFFFFFF, :read)
            end

            def read_16
                lo = read_8(full_pc)
                pbr, pc = increment_pc
                hi = read_8(full_pc(pbr, pc))
                (hi << 8) | lo # Little Endian Word Fetch from Instruction Stream
            end

            def write_8(address, value)
                @memory.access(address & 0xFFFFFF, :write, value & 0xFF)
            end

            def write_16(address, value)
                write_8(address, value & 0xFF)
                write_8(address + 1, (value >> 8) & 0xFF)
            end

            # Effective address using DBR (for Absolute)
            def address_with_dbr(offset)
                (@dbr << 16) | (offset & 0xFFFF)
            end

            # Direct Page mode
            def address_direct_page(offset)
                dp_address = (@dp + offset) & 0xFFFF
                (@dbr << 16) | dp_address
            end

            def address_direct_page_x(offset)
                # Use only 8 bits of X if the X flag is set (index registers are 8-bit)
                x_value = status_p_flag?(:x) ? (@x & 0xFF) : @x

                # Compute 16-bit direct page address
                dp_address = (@dp + offset + x_value) & 0xFFFF

                # Return full 24-bit effective address using the current Data Bank
                (@dbr << 16) | dp_address
            end

            def address_from_absolute_x(offset)
                (@dbr << 16) | ((offset + @x) & 0xFFFF)
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
                "#<CPU PBR=%02X PC=%04X A=%02X X=%02X Y=%02X SP=%04X DP=%02X DBR=%02X Emulation=%s Cycles=%s P=%08b %s>" %
                    [@pbr, @pc, @a, @x, @y, @sp, @dp, @dbr, @emulation_mode, @cycles, @p, WDC65816.debug_format_flags(@p)]
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

            def increment_pc(bytes = 1, pc = @pc, pbr = @pbr)
                pc += bytes
                if pc > 0xFFFF
                    pc &= 0xFFFF
                    pbr = (pbr + 1) & 0xFF if native_mode?
                end
                [pbr, pc]
            end

            def increment_pc!(bytes = 1)
                old_pc = @pc
                @pc += bytes
                increment_cycles_if_page_crossing(old_pc)
                if @pc > 0xFFFF
                    @pc &= 0xFFFF
                    @pbr = (@pbr + 1) & 0xFF if native_mode?
                end
            end

            def full_pc(pbr = @pbr, pc = @pc)
                (pbr << 16) | pc
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