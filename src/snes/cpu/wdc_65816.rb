require_relative 'internal_cpu_registers'
require_relative 'instructions/fetch_data'
require_relative 'instructions/opcodes'
require_relative '../../exceptions/cpu_exceptions'

module Snes
    module CPU
        class WDC65816
            include Instructions::Opcodes
            include Instructions::FetchData

            include Instructions::DataMovement
            include Instructions::ControlFlow
            include Instructions::Arithmetic
            include Instructions::Logical
            include Instructions::BitManipulation
            include Instructions::SubroutineCalls
            include Instructions::SystemControl

            attr_accessor :a, :x, :y, :pc, :sp, :p, :dp, :dbr, :pbr,
                          :cycles, :emulation_mode, :opcodes_table,
                          :current_opcode_data, :emulation_vectors, :native_vectors

            def setup(memory, emulation_vectors, native_vectors, debug=false)
                @debug = debug
                @memory = memory
                reset_addr = emulation_vectors[:reset]
                @emulation_vectors = emulation_vectors
                @native_vectors = native_vectors
                @internal_cpu_registers = Snes::CPU::InternalCPURegisters

                @opcodes_table = Snes::CPU::Instructions::Opcodes::TABLE
                @current_opcode_data = nil

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
                # @x = 0x49
                @x = 00

                # Same above The register can be either 8 or 16 bits
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
                # Z 	    #$02 	00000010 	Zero  (0 = Last operation was not a zero operation, 1 = Last operation was a zero operation)
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

                # Stack Bank
                # @stack_bank = 0

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

            def disassemble(opcode_data = @current_opcode_data)
                handler = opcode_data.handler
                description = opcode_data.description
                addressing_mode = opcode_data.addressing_mode
                p_flags = opcode_data.p_flags
                base_bytes_used = opcode_data.base_bytes_used
                base_cycles = opcode_data.base_cycles

                puts opcode_data if @debug

                # puts "Handler: #{handler}"
                # puts "Description: #{description}"
                # puts "Addressing Mode: #{addressing_mode}"
                # puts "P Flags: #{p_flags.to_s(2).rjust(8, '0')}"
                # puts "Bytes Used: #{base_bytes_used}"
                # puts "Base Cycles: #{base_cycles}"
                puts ""
            end

            def debug_opcode_data(opcode)
                puts "\e[33m0x#{opcode.to_s(16).upcase}\e[0m - #{@current_opcode_data}" if @debug
                # opcode_something = opcode_data.disassemble
                handler = @current_opcode_data.handler
                $cpu_logger.debug("0x%02X - Operation #{handler}" % opcode) if @debug
                # $cpu_logger.debug("Operation #{handler} : #{@pc.to_s(16)}") if @debug
            end

            def get_opcode_data(opcode)
                @current_opcode_data = @opcodes_table[opcode] # 1 cycle for fetching the opcode
                raise CPUOpcodeNotImplementedError.new(opcode), "Opcode 0x%02X not implemented" % opcode unless @current_opcode_data
                debug_opcode_data(opcode) if @debug
            end

            def fetch_decode_execute
                @cycles = 0     # Clear cycles
                @pc &= 0xFFFF   # If PC exceeeds FFFF

                opcode_addr = full_pc(@pbr)
                opcode = read_byte(opcode_addr)

                get_opcode_data(opcode)

                increment_pc! # Because of read_opcode
                @cycles += @current_opcode_data.base_cycles
                result = send(@current_opcode_data.handler) # Call Instruction
            end

            def increment_cycles_if_page_crossing(old_pc)
                # Checks whether X is 16-bit and if the last opcode fetch crossed a page boundary.
                # extra_cycle if necessary
                @cycles += is_page_crossing?(old_pc) ? 1 : 0
            end

            def read_byte(address)
                value = @memory.access(address & 0xFFFFFF, :read)
                # puts "Reading value 0x%02X from address 0x%06X" % [value, address] if @debug
                value
            end

            def read_word(address)
                low = read_byte(address)
                high = read_byte((address + 1) & 0xFFFFFF) # Increment PC by 1
                (high << 8) | low
            end

            def read_long(address)
                low  = read_byte(address)
                mid  = read_byte((address + 1) & 0xFFFFFF) # Increment PC by 1
                high = read_byte((address + 2) & 0xFFFFFF) # Increment PC by 1
                (high << 16) | (mid << 8) | low
            end

            def write_byte(address, value)
                # puts "Writing value 0x%02X to address 0x%06X" % [value, address] if @debug
                @memory.access(address & 0xFFFFFF, :write, value & 0xFF)
            end

            def write_word(address, value) #Works in Low Endian, Given a value example 0x4231
                write_byte(address, value & 0xFF) # Low Byte, value & 0xFF -> 31
                write_byte((address + 1) & 0xFFFFFF, (value >> 8) & 0xFF) # High Byte, (value >> 8) & 0xFF -> 42
            end

            # def write_long(address, value)
            #     write_byte(address, value & 0xFF) # low
            #     write_byte((address + 1) & 0xFFFFFF, (value >> 8) & 0xFF) # Increment PC by 1, mid
            #     write_byte((address + 2) & 0xFFFFFF, (value >> 16) & 0xFF) # Increment PC by 1, high
            # end

            def converts_8bit_unsigned_to_signed(value)
                ((value & 0x80) != 0) ? (value - 0x100) : value
            end


            # Direct Page mode
            # def address_direct_page_x(offset)
            #     # Use only 8 bits of X if the X flag is set (index registers are 8-bit)
            #     x_value = status_p_flag?(:x) ? (@x & 0xFF) : @x
            #
            #     # Compute 16-bit direct page address
            #     dp_address = (@dp + offset + x_value) & 0xFFFF
            #
            #     # Return full 24-bit effective address using the current Data Bank
            #     (@dbr << 16) | dp_address
            # end
            #
            # def address_from_absolute_x(offset)
            #     (@dbr << 16) | ((offset + @x) & 0xFFFF)
            # end

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
                "CPU PC=%02X%04X A=%04X X=%04X Y=%04X SP=%04X DP=%04X DBR=%02X P=%02X Emulation=%s PreviouslyCycles=%s - %s" %
                    [@pbr, @pc, @a, @x, @y, @sp, @dp, @dbr, @p, @emulation_mode, @cycles, WDC65816.debug_format_flags(@p)]
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

            # def increment_pc(bytes = 1, pc = @pc)
            #     (pc + bytes) & 0xFFFF
            # end

            def increment_pc!(bytes = 1)
                old_pc = @pc
                @pc += bytes
                increment_cycles_if_page_crossing(old_pc)
                @pc &= 0xFFFF
            end

            def full_pc(bank, pc = @pc)
                ((bank << 16) | pc)
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
                emulation_mode? && ((old_pc & 0xFF00) != (@pc & 0xFF00))
            end

            def push_byte(value) # to stack
                if @emulation_mode
                    address = 0x0100 | (@sp & 0xFF)
                    @memory.access(address, :write, value & 0xFF)
                    @sp = (@sp - 1) & 0xFF
                else
                    address = @sp
                    @memory.access(address, :write, value & 0xFF)
                    @sp = (@sp - 1) & 0xFFFF
                end
            end

            def push_word(value)
                push_byte(value & 0xFF)        # low byte
                push_byte((value >> 8) & 0xFF) # high byte
            end

            def pull_byte
                if @emulation_mode
                    @sp = (@sp + 1) & 0xFF
                    address = 0x0100 | (@sp & 0xFF)
                    @memory.access(address, :read)
                else
                    @sp = (@sp + 1) & 0xFFFF
                    @memory.access(@sp, :read)
                end
            end

            def pull_word
                low  = pull_byte
                high = pull_byte
                (high << 8) | low
            end

            def set_nz_flags(value, is_8_bit=true)
                if is_8_bit
                    set_p_flag(:z, (value & 0xFF) == 0)
                    set_p_flag(:n, (value & 0x80) != 0)
                else
                    set_p_flag(:z, (value & 0xFFFF) == 0)
                    set_p_flag(:n, (value & 0x8000) != 0)
                end
            end

            def bcd_add_8bit(a, b, carry_in)
                low = (a & 0x0F) + (b & 0x0F) + carry_in
                carry = 0
                if low > 9
                    low = (low + 6) & 0x0F
                    carry = 1
                end

                high = (a >> 4) + (b >> 4) + carry
                if high > 9
                    high = (high + 6) & 0x0F
                    carry_out = true
                else
                    carry_out = false
                end

                result = ((high << 4) | low) & 0xFF
                [result, carry_out]
            end

            def bcd_add_16bit(a, b, carry_in)
                carry = carry_in

                # Add lower byte BCD
                lo, carry_lo = bcd_add_8bit(a & 0xFF, b & 0xFF, carry)
                # Add upper byte BCD with carry from lower
                hi, carry_hi = bcd_add_8bit((a >> 8) & 0xFF, (b >> 8) & 0xFF, carry_lo ? 1 : 0)

                result = (hi << 8) | lo
                carry_out = carry_hi

                [result, carry_out]
            end

        end
    end
end