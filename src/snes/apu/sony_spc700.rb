require_relative 'registers'
require_relative 'instructions/opcodes'
require_relative 'memory'

# Sony SPC700 CPU - it’s an independent 8-bit CPU that communicates with the DSP and receives commands from the main CPU
#
# Clock - 24.576 MHz in both NTSC and PAL system
#
# Music Driver - SPC700 assembly
module Snes::APU
    class SPC700
        # https://github.com/yupferris/TasmShiz/blob/master/spc700.txt
        include Snes::APU::Instructions
        include Snes::APU::Instructions::Opcodes

        attr_accessor :pc, :sp, :a, :x, :y, :ya, :psw
        attr_accessor :cycles, :current_opcode_data, :debug
        attr_accessor :opcodes_table
        attr_accessor :memory

        def setup(debug = false)
            # program counter
            @pc = 0xFFC0

            # stack pointer
            @sp = 0xEF

            # 8-bit accumulator
            @a = 0

            # 8-bit index
            @x = 0

            # 8-bit index
            @y = 0

            # 16-bit pair of A (lsb) and Y (msb).
            @ya = 0

            # program status word: NVPBHIZC
            # N - negative flag (high bit of result was set)
            # V - overflow flag (signed overflow indication)
            # P - direct page flag (moves the direct page to $0100 if set)
            # H - half-carry flag (carry between low and high nibble)
            # I - interrupt enable (unused: the S-SMP has no attached interrupts)
            # Z - zero flag (set if last result was zero)
            # C - carry flag
            @psw = 0x02

            @debug = debug

            @cycles = 0

            @memory = Snes::APU::Memory.new

            @opcodes_table = Snes::APU::Instructions::Opcodes::TABLE
            @current_opcode_data = nil
        end

        def debug_opcode_data(opcode)
            puts "\e[32mAPU\e[0m - \e[33m0x#{opcode.to_s(16).upcase}\e[0m - #{@current_opcode_data}" if @debug
            # opcode_something = opcode_data.disassemble
            handler = @current_opcode_data.handler
            $logger.debug("0x#{opcode.to_s(16)} - Operation #{handler}") if @debug
            # $logger.debug("Operation #{handler} : #{@pc.to_s(16)}") if @debug
        end

        def boot
            puts "[#{Thread.current.name}] Entering SPC700.boot"

            loop do
                puts self.inspect if @debug
                @cycles = 0
                @pc &= 0xFFFF
                opcode = Memory::IPL_ROM[@pc - 0xFFC0]
                break if opcode == 0xFF # Break the loop in the last instruction of IPL ROM
                @current_opcode_data = @opcodes_table[opcode]
                raise NotImplementedError, "Opcode 0x%02X not implemented" % opcode unless @current_opcode_data
                debug_opcode_data(opcode)
                increment_pc! # Always increment PC after fetching an instruction
                send(@current_opcode_data.handler) # Call Instruction
                @cycles += @current_opcode_data.base_cycles
                yield if block_given? # Sleep to syncronize clock
            end

            fetch_decode_execute
        # rescue => e
        #     puts e.message if @debug
        #     puts e.backtrace if @debug
        end

        def fetch_decode_execute
            puts self.inspect if @debug
            @cycles = 0
            @pc &= 0xFFFF
            yield if block_given?
        end

        def read_byte(address)
            # @memory.read(address & 0xFFFF)  # 64KB memory wrapping
            value = @memory.read(address)  # 64KB memory wrapping
            # puts "Reading value 0x%02X from address 0x%06X" % [value, address] if @debug
            value
        end

        def inspect
            "APU PC=%04X A=%02X X=%02X Y=%02X SP=%04X YA=%04X Psw=%02X" %
                [@pc, @a, @x, @y, @sp, @ya, @psw]
            # reg = @registers.all
            # "APU PC=%04X A=%02X X=%02X Y=%02X SP=%04X YA=%04X Psw=%02X - Registers: F4=%02X F5=%02X F6=%02X F7=%02X" %
                # [@pc, @a, @x, @y, @sp, @ya, @psw, reg[0xF4]&.value, reg[0xF5]&.value, reg[0xF6]&.value, reg[0xF7]&.value]
            # [@pc, @a, @x, @y, @sp, @ya , @psw, debug_format_flags(@psw)]
        end

        def increment_pc!(bytes = 1)
            # old_pc = @pc
            @pc += bytes
            # increment_cycles_if_page_crossing(old_pc)
            @pc &= 0xFFFF
        end

        # P modifiers
        def status_p_flag?(symbol)
            mask = {
                n: 0b1000_0000,
                v: 0b0100_0000,
                p: 0b0010_0000,  # not used in SPC700, but included if needed
                b: 0b0001_0000,
                h: 0b0000_1000,
                i: 0b0000_0100,
                z: 0b0000_0010,
                c: 0b0000_0001
            }[symbol]

            (@psw & mask) != 0
        end

        def set_p_flag(symbol, value)
            mask = { n:0x80, v:0x40, p:0x20, b:0x10, h:0x08, i:0x04, z:0x02, c:0x01 }[symbol]
            if value
                @psw |= mask
            else
                @psw &= ~mask & 0xFF
            end
        end

        def set_nz_flags(value)
            @psw ||= 0
            set_p_flag(:z, (value & 0xFF) == 0)
            set_p_flag(:n, (value & 0x80) != 0)
        end
    end
end