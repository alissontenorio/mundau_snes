require_relative 'instructions/opcodes'
require_relative 'internal_cpu_registers'

module Snes
    module CPU
        class WDC65816
            # include Singleton

            include Snes::CPU::Instructions::Opcodes

            include Snes::CPU::Instructions::DataMovement
            include Snes::CPU::Instructions::ControlFlow
            include Snes::CPU::Instructions::Arithmetic
            include Snes::CPU::Instructions::Logical
            include Snes::CPU::Instructions::BitManipulation
            include Snes::CPU::Instructions::SubroutineCalls
            include Snes::CPU::Instructions::SystemControl

            # # Singleton stuff
            # @instance = new
            # private_class_method :new
            # def self.instance; @instance end

            attr_accessor :a, :x, :y, :pc, :sp, :p, :dp, :dbr, :pbr, :cycles, :emulation_mode, :opcodes_table, :current_opcode_data

            def setup(memory, reset_addr, internal_cpu_registers, debug=false)
                @debug = debug
                @memory = memory
                @internal_cpu_registers = internal_cpu_registers

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
                @x = 0

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
                @stack_bank = 0

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
                $logger.debug("0x#{opcode.to_s(16)} - Operation #{handler}") if @debug
                # $logger.debug("Operation #{handler} : #{@pc.to_s(16)}") if @debug
            end

            def get_opcode_data(opcode)
                @current_opcode_data = @opcodes_table[opcode] # 1 cycle for fetching the opcode
                raise NotImplementedError, "Opcode 0x%02X not implemented" % opcode unless @current_opcode_data
                debug_opcode_data(opcode) if @debug
            end

            def fetch_decode_execute
                @cycles = 0     # Clear cycles
                @pc &= 0xFFFF   # If PC exceeeds FFFF

                opcode_addr = full_pc(@pbr)
                opcode = read_8(opcode_addr)

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

            def read_8(address)
                value = @memory.access(address & 0xFFFFFF, :read)
                puts "Reading value 0x%02X from address 0x%06X" % [value, address] if @debug
                value
            end

            def read_16(address)
                lo = read_8(address)
                address = (address + 1) & 0xFFFF # Increment PC by 1
                hi = read_8(address)
                (hi << 8) | lo # Little Endian Word Fetch from Instruction Stream
            end

            def write_8(address, value)
                puts "Writing value 0x%02X to address 0x%06X" % [value, address] if @debug
                @memory.access(address & 0xFFFFFF, :write, value & 0xFF)
            end

            # Given a value example 0x4231
            # value & 0xFF -> 31
            # (value >> 8) & 0xFF -> 42
            def write_16(address, value) #Works in Low Endian
                write_8(address, value & 0xFF) # Low Byte
                write_8(address + 1, (value >> 8) & 0xFF) # High Byte
            end

            # | **Bank Source** | **Addressing Modes**                                          |
            # | --------------- | ------------------------------------------------------------- |
            # | **PBR**         | Instruction fetch, PC-relative control flow                   |
            # | **Bank 0**      | Direct Page, Absolute, Stack-relative, Indirect JMP           |
            # | **DBR**         | All (dp), (dp),Y, \[abs],Y, (S),Y — i.e., indirect data modes |
            # | **Explicit**    | Long addressing, block moves, absolute long JMP/JSR           |
            def fetch_data(p_flag: :m, force_8bit: false)
                case @current_opcode_data.addressing_mode
                when :immediate
                    fetch_immediate(p_flag:, force_8bit:) # uses pbr
                when :absolute
                    fetch_absolute  # bank 0
                when :direct_page
                    fetch_direct_page # bank 0
                when :stack_push
                    nil
                else
                    raise "No mode reach"
                end
            end

            def fetch_immediate(p_flag: :m, force_8bit: false)
                if force_8bit || status_p_flag?(p_flag) # 8-bit - emulation
                    value = read_8(full_pc(@pbr))
                    increment_pc!
                else # 16-bit - native
                    # bytes_used + 1
                    value = read_16(full_pc(@pbr))
                    increment_pc!(2)
                end
                value
            end

            def fetch_absolute
                value = read_16(@pc)  # Fetch 16-bit absolute address
                increment_pc!(2)    # Move PC forward by 2 bytes
                value
            end

            def fetch_direct_page
                offset = read_8(@pc)
                increment_pc!
                (@dp + offset) & 0xFFFF
            end

            # Direct Page mode
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
                "CPU PC=%02X%04X A=%02X X=%02X Y=%02X SP=%04X DP=%02X DBR=%02X Emulation=%s Cycles=%s P=%02X SBR=%02X - %s" %
                    # [@pbr, @pc, @a, @x, @y, @sp, @dp, @dbr, @emulation_mode, @cycles, @p, WDC65816.debug_format_flags(@p)]
                    [@pbr, @pc, @a, @x, @y, @sp, @dp, @dbr, @emulation_mode, @cycles, @p, @stack_bank, WDC65816.debug_format_flags(@p)]
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
                native_mode? && ((old_pc & 0xFF00) != (@pc & 0xFF00))
            end

            def push_8(value) # to stack
                if @emulation_mode
                    address = 0x0100 | (@sp & 0xFF)
                    @memory.access(address, :write, value & 0xFF)
                    @sp = (@sp - 1) & 0xFF
                else
                    address = (@stack_bank << 16) | @sp
                    @memory.access(address, :write, value & 0xFF)
                    @sp = (@sp - 1) & 0xFFFF
                end
            end

            def set_nz_flags(value, is_8_bit)
                if is_8_bit
                    set_p_flag(:z, value & 0xFF == 0)
                    set_p_flag(:n, (value & 0x80) != 0)
                else
                    set_p_flag(:z, (value & 0xFFFF) == 0)
                    set_p_flag(:n, (value & 0x8000) != 0)
                end
            end
        end
    end
end