module Snes
    module CPU
        class InternalCPURegisters
            include Singleton

            # ==== Writable Registers ====
            attr_accessor :nmitimen   # Interrupt Enable Register         ($4200)
            attr_accessor :wrio       # IO Port Write Register            ($4201)
            attr_accessor :wrmpya     # Multiplicand Register A           ($4202)
            attr_accessor :wrmpyb     # Multiplicand Register B           ($4203)
            attr_accessor :wrdivl     # Dividend (Low Byte)               ($4204)
            attr_accessor :wrdivh     # Dividend (High Byte)              ($4205)
            attr_accessor :wrdivb     # Divisor                           ($4206)
            attr_accessor :htimel     # IRQ Timer Horizontal (Low)        ($4207)
            attr_accessor :htimeh     # IRQ Timer Horizontal (High)       ($4208)
            attr_accessor :vtimel     # IRQ Timer Vertical (Low)          ($4209)
            attr_accessor :vtimeh     # IRQ Timer Vertical (High)         ($420A)
            attr_accessor :mdmaen     # DMA Enable Register               ($420B)
            attr_accessor :hdmaen     # HDMA Enable Register              ($420C)
            attr_accessor :memsel     # ROM Speed Register                ($420D)

            # ==== Readable Registers ====
            attr_accessor :rdnmi      # Interrupt Flag Register - NMI     ($4210)
            attr_accessor :timeup     # Interrupt Flag Register - IRQ     ($4211)
            attr_accessor :hvbjoy     # PPU Status Register               ($4212)
            attr_accessor :rdio       # IO Port Read Register             ($4213)
            attr_accessor :rddivl     # Division Result (Low Byte)        ($4214)
            attr_accessor :rddivh     # Division Result (High Byte)       ($4215)
            attr_accessor :rdmpyl     # Multiplication Result (Low Byte)  ($4216)
            attr_accessor :rdmpyh     # Multiplication Result (High Byte) ($4217)
            attr_accessor :joy1l      # Controller Port 1 Data (Low)      ($4218)
            attr_accessor :joy1h      # Controller Port 1 Data (High)     ($4219)
            attr_accessor :joy2l      # Controller Port 2 Data (Low)      ($421A)
            attr_accessor :joy2h      # Controller Port 2 Data (High)     ($421B)
            attr_accessor :joy3l      # Controller Port 3 Data (Low)      ($421C)
            attr_accessor :joy3h      # Controller Port 3 Data (High)     ($421D)
            attr_accessor :joy4l      # Controller Port 4 Data (Low)      ($421E)
            attr_accessor :joy4h      # Controller Port 4 Data (High)     ($421F)

            WRITE_MAP = {
                0x4200 => :nmitimen,
                0x4201 => :wrio,
                0x4202 => :wrmpya,
                0x4203 => :wrmpyb,
                0x4204 => :wrdivl,
                0x4205 => :wrdivh,
                0x4206 => :wrdivb,
                0x4207 => :htimel,
                0x4208 => :htimeh,
                0x4209 => :vtimel,
                0x420A => :vtimeh,
                0x420B => :mdmaen,
                0x420C => :hdmaen,
                0x420D => :memsel
            }.freeze

            READ_MAP = {
                0x4210 => :rdnmi,
                0x4211 => :timeup,
                0x4212 => :hvbjoy,
                0x4213 => :rdio,
                0x4214 => :rddivl,
                0x4215 => :rddivh,
                0x4216 => :rdmpyl,
                0x4217 => :rdmpyh,
                0x4218 => :joy1l,
                0x4219 => :joy1h,
                0x421A => :joy2l,
                0x421B => :joy2h,
                0x421C => :joy3l,
                0x421D => :joy3h,
                0x421E => :joy4l,
                0x421F => :joy4h
            }.freeze

            def initialize
                # Initialize all registers to 0
                (WRITE_MAP.values + READ_MAP.values).uniq.each do |reg|
                    instance_variable_set("@#{reg}", 0)
                end
            end

            def read(address)
                register = READ_MAP[address]
                if register
                    send(register)
                else
                    raise "Read access to invalid or write-only address: 0x#{address.to_s(16).upcase}"
                end
            end

            def write(address, value)
                register = WRITE_MAP[address]
                if register
                    send("#{register}=", value)
                else
                    raise "Write access to invalid or read-only address: 0x#{address.to_s(16).upcase}"
                end
            end

            def address_to_symbol(address)
                WRITE_MAP[address] || READ_MAP[address] || :unknown
            end
        end
    end
end