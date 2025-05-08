module Snes
    module PPU
        class Registers
            class Register
                attr_accessor :value
                attr_reader :name, :description

                def initialize(name, description)
                    @name = name
                    @description = description
                    @value = 0
                end
            end

            # Criação dos objetos de registrador
            @registers = {
                0x2100 => Register.new("INIDISP", "Screen Display Register"),
                0x2101 => Register.new("OBSEL",   "Object Size and Character Size Register"),
                0x2102 => Register.new("OAMADDL", "OAM Address Registers (Low)"),
                0x2103 => Register.new("OAMADDH", "OAM Address Registers (High)"),
                0x2104 => Register.new("OAMDATA", "OAM Data Write Register"),
                0x2105 => Register.new("BGMODE",  "BG Mode and Character Size Register"),
                0x2106 => Register.new("MOSAIC",  "Mosaic Register"),
                0x2107 => Register.new("BG1SC",   "BG Tilemap Address Registers (BG1)"),
                0x2108 => Register.new("BG2SC",   "BG Tilemap Address Registers (BG2)"),
                0x2109 => Register.new("BG3SC",   "BG Tilemap Address Registers (BG3)"),
                0x210A => Register.new("BG4SC",   "BG Tilemap Address Registers (BG4)"),
                0x210B => Register.new("BG12NBA", "BG Character Address Registers (BG1 & 2)"),
                0x210C => Register.new("BG34NBA", "BG Character Address Registers (BG3 & 4)"),
                0x210D => Register.new("BG1HOFS", "BG Scroll Registers (BG1)"),
                0x210E => Register.new("BG1VOFS", "BG Scroll Registers (BG1)"),
                0x210F => Register.new("BG2HOFS", "BG Scroll Registers (BG2)"),
                0x2110 => Register.new("BG2VOFS", "BG Scroll Registers (BG2)"),
                0x2111 => Register.new("BG3HOFS", "BG Scroll Registers (BG3)"),
                0x2112 => Register.new("BG3VOFS", "BG Scroll Registers (BG3)"),
                0x2113 => Register.new("BG4HOFS", "BG Scroll Registers (BG4)"),
                0x2114 => Register.new("BG4VOFS", "BG Scroll Registers (BG4)"),
                0x2115 => Register.new("VMAIN",   "Video Port Control Register"),
                0x2116 => Register.new("VMADDL",  "VRAM Address Registers (Low)"),
                0x2117 => Register.new("VMADDH",  "VRAM Address Registers (High)"),
                0x2118 => Register.new("VMDATAL", "VRAM Data Write Registers (Low)"),
                0x2119 => Register.new("VMDATAH", "VRAM Data Write Registers (High)"),
                0x211A => Register.new("M7SEL",   "Mode 7 Settings Register"),
                0x211B => Register.new("M7A",     "Mode 7 Matrix Registers"),
                0x211C => Register.new("M7B",     "Mode 7 Matrix Registers"),
                0x211D => Register.new("M7C",     "Mode 7 Matrix Registers"),
                0x211E => Register.new("M7D",     "Mode 7 Matrix Registers"),
                0x211F => Register.new("M7X",     "Mode 7 Matrix Registers"),
                0x2120 => Register.new("M7Y",     "Mode 7 Matrix Registers"),
                0x2121 => Register.new("CGADD",   "CGRAM Address Register"),
                0x2122 => Register.new("CGDATA",  "CGRAM Data Write Register"),
                0x2123 => Register.new("W12SEL",  "Window Mask Settings Registers"),
                0x2124 => Register.new("W34SEL",  "Window Mask Settings Registers"),
                0x2125 => Register.new("WOBJSEL", "Window Mask Settings Registers"),
                0x2126 => Register.new("WH0",     "Window Position Registers (WH0)"),
                0x2127 => Register.new("WH1",     "Window Position Registers (WH1)"),
                0x2128 => Register.new("WH2",     "Window Position Registers (WH2)"),
                0x2129 => Register.new("WH3",     "Window Position Registers (WH3)"),
                0x212A => Register.new("WBGLOG",  "Window Mask Logic Registers (BG)"),
                0x212B => Register.new("WOBJLOG", "Window Mask Logic Registers (OBJ)"),
                0x212C => Register.new("TM",      "Screen Destination Registers"),
                0x212D => Register.new("TS",      "Screen Destination Registers"),
                0x212E => Register.new("TMW",     "Window Mask Destination Registers"),
                0x212F => Register.new("TSW",     "Window Mask Destination Registers"),
                0x2130 => Register.new("CGWSEL",  "Color Math Registers"),
                0x2131 => Register.new("CGADSUB", "Color Math Registers"),
                0x2132 => Register.new("COLDATA", "Color Math Registers"),
                0x2133 => Register.new("SETINI",  "Screen Mode Select Register"),
                0x2134 => Register.new("MPYL",    "Multiplication Result Registers"),
                0x2135 => Register.new("MPYM",    "Multiplication Result Registers"),
                0x2136 => Register.new("MPYH",    "Multiplication Result Registers"),
                0x2137 => Register.new("SLHV",    "Software Latch Register"),
                0x2138 => Register.new("OAMDATAREAD", "OAM Data Read Register"),
                0x2139 => Register.new("VMDATALREAD", "VRAM Data Read Register (Low)"),
                0x213A => Register.new("VMDATAHREAD", "VRAM Data Read Register (High)"),
                0x213B => Register.new("CGDATAREAD",  "CGRAM Data Read Register"),
                0x213C => Register.new("OPHCT",       "Scanline Location Registers (Horizontal)"),
                0x213D => Register.new("OPVCT",       "Scanline Location Registers (Vertical)"),
                0x213E => Register.new("STAT77",      "PPU Status Register"),
                0x213F => Register.new("STAT78",      "PPU Status Register"),
                0x2180 => Register.new("WMDATA",  "WRAM Data Register"),
                0x2181 => Register.new("WMADDL",  "WRAM Address Registers"),
                0x2182 => Register.new("WMADDM",  "WRAM Address Registers"),
                0x2183 => Register.new("WMADDH",  "WRAM Address Registers"),
            }

            class << self
                def access(operation, address, value = nil)
                    reg = @registers[address]
                    raise "Invalid register address: 0x#{address.to_s(16)}" unless reg

                    case operation
                    when :read
                        reg.value
                    when :write_register
                        reg.value = value & 0xFF
                    else
                        raise "Unknown operation: #{operation}"
                    end
                end

                def info(address)
                    reg = @registers[address]
                    return nil unless reg
                    { name: reg.name, description: reg.description, value: reg.value }
                end

                def debug_print(operation, address, value = nil)
                    info = info(address)
                    write = value ? (" value " + value.to_s(16)) : ''
                    $logger.debug("PPU Register - #{operation.to_s.capitalize} in address #{address.to_s(16)}#{write} - #{info[:name]} - #{info[:description]}\n")
                    puts "\e[31mPPU\e[0m register - #{operation.to_s.capitalize}#{write} in address #{address.to_s(16)} - \e[31m#{info[:name]}\e[0m - #{info[:description]}"
                end

                def all
                    @registers
                end
            end
        end
    end
end
