require_relative 'register'
require_relative 'instructions/opcodes'
require_relative 'memory'
require_relative '../../exceptions/apu_exceptions'

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
            # @ya = 0 # YA is a virtual 16-bit SPC700 register who's high byte is the Y index register and who's low byte is accumulator

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
            @memory.setup(@debug)

            @opcodes_table = Snes::APU::Instructions::Opcodes::TABLE
            @current_opcode_data = nil
        end

        def read(address) # For Bus use
            value = @memory.read_register_from_bus(address & 0xFFFF)
            puts "APU - Bus - Reading value 0x%02X from address 0x%04X" % [value, address] if @debug
            $apu_logger.debug("Bus - Reading value 0x%02X from address 0x%04X" % [value, address]) if @debug
            value
        end

        def write(address, value) # For Bus use
            puts "APU - Bus - Writing value 0x%02X to address 0x%04X" % [value, address] if @debug
            $apu_logger.debug("Bus - Writing value 0x%02X to address 0x%04X" % [value, address]) if @debug
            @memory.write_register_from_bus(address, value)
        end

        def debug_opcode_data
            puts "\e[32mAPU\e[0m - \e[33m0x#{@current_opcode_data[0].to_s(16).upcase}\e[0m - #{@current_opcode_data[1]}"
            # opcode_something = opcode_data.disassemble
            handler = @current_opcode_data[1].handler
            $apu_logger.debug("0x#{@current_opcode_data[0].to_s(16)} - Operation #{handler}")
            # $logger.debug("Operation #{handler} : #{@pc.to_s(16)}")
        end

        def boot
            $apu_logger.debug("[#{Thread.current.name}] Entering SPC700.boot") if @debug

            loop do
                @cycles = 0
                @pc &= 0xFFFF
                opcode = Memory::IPL_ROM[@pc - 0xFFC0]
                break if opcode == 0xFF # Break the loop in the last instruction of IPL ROM
                @current_opcode_data = opcode, @opcodes_table[opcode]
                raise APUOpcodeNotImplementedError.new(opcode), "Opcode 0x%02X not implemented" % opcode unless @current_opcode_data[1]

                if @debug
                    # && opcode != 0x8F && opcode != 0xD0 && opcode != 0x1D
                    $apu_logger.debug(self.inspect)
                    puts
                    puts self.inspect
                    debug_opcode_data
                end
                increment_pc! # Always increment PC after fetching an instruction
                send(@current_opcode_data[1].handler) # Call Instruction
                @cycles += @current_opcode_data[1].base_cycles
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
            # get opcode
            # break?
            @current_opcode_data = opcode, @opcodes_table[opcode]
            raise APUOpcodeNotImplementedError, "Opcode 0x%02X not implemented" % opcode unless @current_opcode_data[1]
            debug_opcode_data
            increment_pc!
            send(@current_opcode_data[1].handler) # Call Instruction
            @cycles += @current_opcode_data[1].base_cycles
            yield if block_given?
        end

        def read_byte(address)
            # @memory.read(address & 0xFFFF)  # 64KB memory wrapping
            value = @memory.read(address & 0xFFFF)  # 64KB memory wrapping
            if @debug && !value.nil?
                puts "APU - 0x#{@current_opcode_data[0].to_s(16)} - Operation #{@current_opcode_data[1].handler} - PC: #{(@pc- 0xFFC0).to_s(16)} - Reading value 0x%02X from address 0x%04X - SPC700" % [value, address]
                $apu_logger.debug("0x#{@current_opcode_data[0].to_s(16)} - Operation #{@current_opcode_data[1].handler} - PC: #{(@pc- 0xFFC0).to_s(16)} - Reading value 0x%02X from address 0x%04X - SPC700" % [value, address])
            end
            value
        end

        def write_byte(address, value)
            puts "APU - 0x#{@current_opcode_data[0].to_s(16)} - Operation #{@current_opcode_data[1].handler} - PC: #{(@pc- 0xFFC0).to_s(16)} - Writing value 0x%02X to address 0x%04X - SPC700" % [value, address] if @debug
            $apu_logger.debug("0x#{@current_opcode_data[0].to_s(16)} - Operation #{@current_opcode_data[1].handler} - PC: #{(@pc- 0xFFC0).to_s(16)} - Writing value 0x%02X to address 0x%04X - SPC700" % [value, address]) if @debug
            @memory.write(address, value)
        end

        def inspect
            "APU PC=%04X A=%02X X=%02X Y=%02X SP=%02X PSW=%02X" %
                [@pc, @a, @x, @y, @sp, @psw]
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

        def set_nz_flags(value, is_8_bit = true)
            @psw ||= 0
            if is_8_bit
                set_p_flag(:z, (value & 0xFF) == 0)
                set_p_flag(:n, (value & 0x80) != 0)
            else
                set_p_flag(:z, (value & 0xFFFF) == 0)
                set_p_flag(:n, (value & 0x8000) != 0)
            end
        end

        def converts_8bit_unsigned_to_signed(value)
            ((value & 0x80) != 0) ? (value - 0x100) : value
        end
    end
end
