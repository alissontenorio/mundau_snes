require 'logger'

module Snes::APU
    class Memory
        # /*ffc0*/  0xcd, 0xef,        //mov   x,#$ef
        # /*ffc2*/  0xbd,              //mov   sp,x
        # /*ffc3*/  0xe8, 0x00,        //mov   a,#$00
        # /*ffc5*/  0xc6,              //mov   (x),a
        # /*ffc6*/  0x1d,              //dec   x
        # /*ffc7*/  0xd0, 0xfc,        //bne   $ffc5
        # /*ffc9*/  0x8f, 0xaa, 0xf4,  //mov   $f4,#$aa
        # /*ffcc*/  0x8f, 0xbb, 0xf5,  //mov   $f5,#$bb
        # /*ffcf*/  0x78, 0xcc, 0xf4,  //cmp   $f4,#$cc
        # /*ffd2*/  0xd0, 0xfb,        //bne   $ffcf
        # /*ffd4*/  0x2f, 0x19,        //bra   $ffef
        # /*ffd6*/  0xeb, 0xf4,        //mov   y,$f4
        # /*ffd8*/  0xd0, 0xfc,        //bne   $ffd6
        # /*ffda*/  0x7e, 0xf4,        //cmp   y,$f4
        # /*ffdc*/  0xd0, 0x0b,        //bne   $ffe9
        # /*ffde*/  0xe4, 0xf5,        //mov   a,$f5
        # /*ffe0*/  0xcb, 0xf4,        //mov   $f4,y
        # /*ffe2*/  0xd7, 0x00,        //mov   ($00)+y,a
        # /*ffe4*/  0xfc,              //inc   y
        # /*ffe5*/  0xd0, 0xf3,        //bne   $ffda
        # /*ffe7*/  0xab, 0x01,        //inc   $01
        # /*ffe9*/  0x10, 0xef,        //bpl   $ffda
        # /*ffeb*/  0x7e, 0xf4,        //cmp   y,$f4
        # /*ffed*/  0x10, 0xeb,        //bpl   $ffda
        # /*ffef*/  0xba, 0xf6,        //movw  ya,$f6
        # /*fff1*/  0xda, 0x00,        //movw  $00,ya
        # /*fff3*/  0xba, 0xf4,        //movw  ya,$f4
        # /*fff5*/  0xc4, 0xf4,        //mov   $f4,a
        # /*fff7*/  0xdd,              //mov   a,y
        # /*fff8*/  0x5d,              //mov   x,a
        # /*fff9*/  0xd0, 0xdb,        //bne   $ffd6
        # /*fffb*/  0x1f, 0x00, 0x00,  //jmp   ($0000+x)
        # /*fffe*/  0xc0, 0xff         //reset vector location ($ffc0)
        # 64 bytes IPL ROM
        IPL_ROM = [
            0xCD, 0xEF, 0xBD, 0xE8, 0x00, 0xC6, 0x1D, 0xD0, 0xFC, 0x8F,
            0xAA, 0xF4, 0x8F, 0xBB, 0xF5, 0x78, 0xCC, 0xF4, 0xD0, 0xFB,
            0x2F, 0x19, 0xEB, 0xF4, 0xD0, 0xFC, 0x7E, 0xF4, 0xD0, 0x0B,
            0xE4, 0xF5, 0xCB, 0xF4, 0xD7, 0x00, 0xFC, 0xD0, 0xF3, 0xAB,
            0x01, 0x10, 0xEF, 0x7E, 0xF4, 0x10, 0xEB, 0xBA, 0xF6, 0xDA,
            0x00, 0xBA, 0xF4, 0xC4, 0xF4, 0xDD, 0x5D, 0xD0, 0xDB, 0x1F,
            0x00, 0x00, 0xC0, 0xFF
        ]

        CPU_TO_APU_IO = {
            0x2140 => 0xF4,
            0x2141 => 0xF5,
            0x2142 => 0xF6,
            0x2143 => 0xF7
        }

        attr_accessor :aram, :registers, :ipl_writable, :debug

        def setup(debug = false)
            # Upon power-up, APU RAM tends to contain a stable repeating 64-byte pattern: 32x00h, 32xFFh
            # (that, for APUs with two Motorola MCM51L832F12 32Kx8 SRAM chips; other consoles may use different chips
            # with different garbage/patterns). After Reset, the boot ROM changes [0000h..0001h]=Entrypoint, and [0002h..00EFh]=00h).
            @aram = Array.new(0x10000, 0)       # Full 64KB RAM
            # Registers - For 0x00F0–0x00FF I/O
            @registers = RegisterBank.new
            @debug = debug
        end

        def read(address)
            access(address) { |mem, addr| mem[addr] }
        end

        def write(address, value)
            if address >= 0xFFC0 && address <= 0xFFFF # IPL rom
                $apu_logger.warn("Attempted write to restricted address range: 0x%04X" % address)
                return
            end

            access(address) { |mem, addr| mem[addr] = value }
        end

        def read_register_from_bus(address)
            reg = CPU_TO_APU_IO[address]
            raise "Invalid register address: 0x#{address.to_s(16)}" unless reg
            read(reg)
        end

        def write_register_from_bus(address, value)
            reg = CPU_TO_APU_IO[address]
            raise "Invalid register address: 0x#{address.to_s(16)}" unless reg
            write(reg, value)
        end

        private

        # Range 	Note
        # $0000-00EF 	Zero Page RAM
        # $00F0-00FF 	Sound CPU Registers
        # $0100-01FF 	Stack Page RAM
        # $0200-FFBF 	RAM
        # $FFC0-FFFF 	IPL ROM or RAM
        def access(address, &block)
            raise "No block given to access" unless block_given?

            case address
            when 0x0000..0x00EF  # Zero Page RAM (typically used for CPU pointers/variables)
                access_ram(address, &block)
            when 0x00F0..0x00FF  # Sound CPU Registers # I/O Ports (writes are also passed to RAM)
                access_register(address, &block)
            when 0x0100..0x01FF  # Stack Page RAM # (typically used for CPU stack)
                access_ram(address, &block)
            when 0x0200..0xFFBF  # RAM # (code, data, dir-table, brr-samples, echo-buffer, etc.)
                access_ram(address, &block)
            when 0xFFC0..0xFFFF  # IPL ROM or RAM (selectable via Port 00F1h)
                access_ipl_rom(address, &block)
            else
                raise "Invalid memory access at #{address.to_s(16)}"
            end
        end

        def access_ram(address)
            yield(@aram, address)
        end

        def access_stack(address)
            yield(@aram, address) # Stack is just a special region in RAM
        end

        def access_register(address)
            # Address 	Description 	R/W
            # $00F0 	Unknown 	?
            # $00F1 	Control 	W
            # $00F2 	DSP Read/Write Address 	R/W
            # $00F3 	DSP Read/Write Data 	R/W
            # $00F4 	Port 0 	R/W
            # $00F5 	Port 1 	R/W
            # $00F6 	Port 2 	R/W
            # $00F7 	Port 3 	R/W
            # $00FA 	Timer Setting 0 	W
            # $00FB 	Timer Setting 1 	W
            # $00FC 	Timer Setting 2 	W
            # $00FA 	Timer Counter 0 	R
            # $00FB 	Timer Counter 1 	R
            # $00FC 	Timer Counter 2 	R
            yield(@registers, address)
        end

        def access_ipl_rom(address)
            offset = address - 0xFFC0
            yield(IPL_ROM, offset)
        end

        # def read_register(address)
        #     @registers[address] || 0 # Fallback default value
        # end
        #
        # def write_register(address, value)
        #     @registers[address] = value
        # end
    end
end