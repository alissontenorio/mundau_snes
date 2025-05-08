require_relative 'registers'

# Sony SPC700 CPU - it’s an independent 8-bit CPU that communicates with the DSP and receives commands from the main CPU
#
# Clock - 24.576 MHz in both NTSC and PAL system
#
# Music Driver - SPC700 assembly
module Snes::APU
    class SPC700BKP
        attr_accessor :f4, :f5, :f6, :f7
        attr_reader :enabled, :ram, :registers

        CPU_TO_APU_IO = {
            0x2140 => 0xF4,
            0x2141 => 0xF5,
            0x2142 => 0xF6,
            0x2143 => 0xF7
        }

        def setup(debug = false)
            @registers = Snes::APU::Registers
            # 0x0000–0x00EF	RAM zerada no boot pelo código da APU
            # 0x00F0–0x00FF	Reservado (I/O + stack no topo)
            # 0x0100–0x01FF	Stack (geralmente começa em 0x01EF)
            # 0x0200	Entrada padrão para carregar código da CPU
            @ram = Array.new(64 * 1024, 0) # 64KB APU RAM

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

            # Estado da execução
            @enabled = false

            @debug = debug

            # @samples = load_samples
            # @sequences = load_sequences
            # @effects = load_effects
        end

        def update_zero_flag
            if @a == 0
                @psw |= 0x02  # Define o flag Zero (Z) no PSW
            else
                @psw &= ~0x02 # Limpa o flag Zero (Z) no PSW
            end
        end

        def update_negative_flag
            if (@a & 0x80) != 0
                @psw |= 0x80  # Define o flag Negativo (N) no PSW
            else
                @psw &= ~0x80 # Limpa o flag Negativo (N) no PSW
            end
        end

        def mov_x_immediate(value)
            @x = value & 0xFF  # O valor é limitado a 8 bits (0xFF)
        end

        def mov_sp_x
            @sp = @x & 0xFF  # Transfere o valor de X para SP, limitando a 8 bits
        end

        def mov_a_immediate(value)
            @a = value & 0xFF  # Garante que o valor seja apenas de 8 bits
            update_zero_flag
            update_negative_flag
        end

        # It stores the value of the accumulator A into the memory address pointed to by the X register.
        def mov_indirect_x_a
            address = @x & 0xFF  # Ensure 8-bit wraparound
            @ram[address] = @a & 0xFF  # Store lower 8 bits of A into RAM[X]
        end

        def dec_x
            @x -= 1
            @x &= 0xFF  # Garante que o valor de X seja de 8 bits (0x00 - 0xFF)

            update_zero_flag
            update_negative_flag
        end

        # 0x00
        def nop
            # No operation — apenas consome ciclos.
            increment_pc
        end

        def increment_pc
            @pc = (@pc + 1) & 0xFFFF
        end

        def print_ram(start = 0x00, length = 0x100)
            end_addr = [start + length, @ram.size].min
            (start...end_addr).each_slice(16) do |slice|
                hex_values = slice.map { |addr| "%02X" % @ram[addr] }.join(" ")
                puts "%02X: %s" % [slice.first, hex_values]
            end
        end

        def boot
            # 1. Set SP = $EF
            mov_x_immediate(0xEF)   # mov x,#$ef    # Set stack pointer to $EF
            mov_sp_x               # mov sp,x
            mov_a_immediate(0x00)   # mov a,#$00

            # 2. Clear RAM from $00 to $EF
            mov_indirect_x_a       # mov (x),a      #  Clear part of RAM (usually from $0100 down to $0000)
            dec_x                  # dec x

            loop do
                mov_indirect_x_a     # mov (x),a
                dec_x                # dec x
                break if @x == 0x00
                yield if block_given?
            end

            # 3. Initialize APU I/O ports
            # Reset APU ports
            mov_a_immediate(0x00)
            @registers.write_apu_io_registers({
               0xF4 => 0x00,  # Inicializa APUIO0 com 0x00
               0xF5 => 0x00,  # Inicializa APUIO1 com 0x00
               0xF6 => 0x00,  # Inicializa APUIO2 com 0x00
               0xF7 => 0x00   # Inicializa APUIO3 com 0x00
            })

            # 4. Receive code/data from SNES and store into RAM at $0200+
            ram_addr = 0x0200

            loop do
                # Read 4 bytes from SNES (via APU I/O ports)
                ports = @registers.read_apu_io_registers(CPU_TO_APU_IO.values)

                # 0x00 signals "no data" or wait
                if ports.values.all? { |b| b == 0x00 }
                    yield if block_given?
                    next  # keep waiting
                end

                puts "Break the loop: #{ports}" if @debug

                ports.each_value do |byte|
                    break if byte == 0xFF # 0xFF signals end of transmission
                    @ram[ram_addr] = byte
                    ram_addr += 1
                    yield if block_given?
                end
            end

            # 5. Jump to uploaded code (entry point at $0200)
            @pc = 0x0200
        end

        def inspect
            reg = @registers.all
            "APU PC=%04X A=%02X X=%02X Y=%02X SP=%04X YA=%04X Psw=%02X - Registers: F4=%02X F5=%02X F6=%02X F7=%02X" %
                [@pc, @a, @x, @y, @sp, @ya, @psw, reg[0xF4]&.value, reg[0xF5]&.value, reg[0xF6]&.value, reg[0xF7]&.value]
                # [@pc, @a, @x, @y, @sp, @psw, debug_format_flags(@psw)]
        end

        def fetch_byte
            puts "Fetching byte from PC: 0x%04X" % @pc if @debug
            byte = @ram[@pc]
            puts "Byte fetched: 0x%02X" % byte if @debug
            @pc = (@pc + 1) & 0xFFFF  # wrap around 16-bit address space
            byte
        end

        def step
            # return unless @enabled
            opcode = fetch_byte
            execute_opcode(opcode)
            yield if block_given?
        end

        def execute_opcode(opcode)
            puts "Executing opcode: 0x%02X" % opcode if @debug
            case opcode
            when 0x00 then nop
            when 0xE8 then mov_a_immediate(fetch_byte)   # mov a, #imm
            # when 0xC4 then mov_dp_a(fetch_byte)          # mov dp, a
            # when 0x5F then jmp_absolute(fetch_byte, fetch_byte)  # jmp addr
            else
                raise "Unknown opcode: 0x%02X" % opcode
            end
        end


        # def reset
        #     @pc = read_word(0xFFFE) # vetor de reset
        #     @sp = 0xFF
        #     @enabled = false
        #     puts "APU Reset: PC=#{@pc.to_s(16).rjust(4, '0')}"
        # end

        def write_register(address, value)
            apu_addr = CPU_TO_APU_IO[address]
            raise "Invalid APU I/O address: $#{address.to_s(16).upcase}" unless apu_addr
            @registers.access(:write, apu_addr, value)
        end

        def read_register(address)
            # @registers.access(:read, address)
            apu_addr = CPU_TO_APU_IO[address]
            raise "Invalid APU I/O address: $#{address.to_s(16).upcase}" unless apu_addr
            @registers.access(:read, apu_addr)
        end

        def write_ram(address, value)
            @ram[address & 0xFFFF] = value & 0xFF
        end

        def read_ram(address)
            @ram[address & 0xFFFF]
        end
    end
end
