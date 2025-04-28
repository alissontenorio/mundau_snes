module Snes
    module PPU
        class Registers
            # Updated constant with register name, initial value, and description
            REGISTER_MAP = {
                0x2100 => ["INIDISP", 0, "Screen Display Register"],               # PPU desliga ou liga o vídeo
                0x2101 => ["OBSEL", 0, "Object Size and Character Size Register"],
                0x2102 => ["OAMADDL", 0, "OAM Address Registers (Low)"],
                0x2103 => ["OAMADDH", 0, "OAM Address Registers (High)"],
                0x2104 => ["OAMDATA", 0, "OAM Data Write Register"],
                0x2105 => ["BGMODE", 0, "BG Mode and Character Size Register"],
                0x2106 => ["MOSAIC", 0, "Mosaic Register"],
                0x2107 => ["BG1SC", 0, "BG Tilemap Address Registers (BG1)"],
                0x2108 => ["BG2SC", 0, "BG Tilemap Address Registers (BG2)"],
                0x2109 => ["BG3SC", 0, "BG Tilemap Address Registers (BG3)"],
                0x210A => ["BG4SC", 0, "BG Tilemap Address Registers (BG4)"],
                0x210B => ["BG12NBA", 0, "BG Character Address Registers (BG1 & 2)"],
                0x210C => ["BG34NBA", 0, "BG Character Address Registers (BG3 & 4)"],
                0x210D => ["BG1HOFS", 0, "BG Scroll Registers (BG1)"],
                0x210E => ["BG1VOFS", 0, "BG Scroll Registers (BG1)"],
                0x210F => ["BG2HOFS", 0, "BG Scroll Registers (BG2)"],
                0x2110 => ["BG2VOFS", 0, "BG Scroll Registers (BG2)"],
                0x2111 => ["BG3HOFS", 0, "BG Scroll Registers (BG3)"],
                0x2112 => ["BG3VOFS", 0, "BG Scroll Registers (BG3)"],
                0x2113 => ["BG4HOFS", 0, "BG Scroll Registers (BG4)"],
                0x2114 => ["BG4VOFS", 0, "BG Scroll Registers (BG4)"],
                0x2115 => ["VMAIN", 0, "Video Port Control Register"],
                0x2116 => ["VMADDL", 0, "VRAM Address Registers (Low)"],
                0x2117 => ["VMADDH", 0, "VRAM Address Registers (High)"],
                0x2118 => ["VMDATAL", 0, "VRAM Data Write Registers (Low)"],         # Dados de gráfico são enviados à PPU
                0x2119 => ["VMDATAH", 0, "VRAM Data Write Registers (High)"],
                0x211A => ["M7SEL", 0, "Mode 7 Settings Register"],
                0x211B => ["M7A", 0, "Mode 7 Matrix Registers"],
                0x211C => ["M7B", 0, "Mode 7 Matrix Registers"],
                0x211D => ["M7C", 0, "Mode 7 Matrix Registers"],
                0x211E => ["M7D", 0, "Mode 7 Matrix Registers"],
                0x211F => ["M7X", 0, "Mode 7 Matrix Registers"],
                0x2120 => ["M7Y", 0, "Mode 7 Matrix Registers"],
                0x2121 => ["CGADD", 0, "CGRAM Address Register"],
                0x2122 => ["CGDATA", 0, "CGRAM Data Write Register"],
                0x2123 => ["W12SEL", 0, "Window Mask Settings Registers"],
                0x2124 => ["W34SEL", 0, "Window Mask Settings Registers"],
                0x2125 => ["WOBJSEL", 0, "Window Mask Settings Registers"],
                0x2126 => ["WH0", 0, "Window Position Registers (WH0)"],
                0x2127 => ["WH1", 0, "Window Position Registers (WH1)"],
                0x2128 => ["WH2", 0, "Window Position Registers (WH2)"],
                0x2129 => ["WH3", 0, "Window Position Registers (WH3)"],
                0x212A => ["WBGLOG", 0, "Window Mask Logic Registers (BG)"],
                0x212B => ["WOBJLOG", 0, "Window Mask Logic Registers (OBJ)"],
                0x212C => ["TM", 0, "Screen Destination Registers"],
                0x212D => ["TS", 0, "Screen Destination Registers"],
                0x212E => ["TMW", 0, "Window Mask Destination Registers"],
                0x212F => ["TSW", 0, "Window Mask Destination Registers"],
                0x2130 => ["CGWSEL", 0, "Color Math Registers"],
                0x2131 => ["CGADSUB", 0, "Color Math Registers"],
                0x2132 => ["COLDATA", 0, "Color Math Registers"],
                0x2133 => ["SETINI", 0, "Screen Mode Select Register"],
                0x2134 => ["MPYL", 0, "Multiplication Result Registers"],
                0x2135 => ["MPYM", 0, "Multiplication Result Registers"],
                0x2136 => ["MPYH", 0, "Multiplication Result Registers"],
                0x2137 => ["SLHV", 0, "Software Latch Register"],                             # CPU descobre se pode fazer DMA, por exemplo
                0x2138 => ["OAMDATAREAD", 0, "OAM Data Read Register"],
                0x2139 => ["VMDATALREAD", 0, "VRAM Data Read Register (Low)"],
                0x213A => ["VMDATAHREAD", 0, "VRAM Data Read Register (High)"],
                0x213B => ["CGDATAREAD", 0, "CGRAM Data Read Register"],
                0x213C => ["OPHCT", 0, "Scanline Location Registers (Horizontal)"],
                0x213D => ["OPVCT", 0, "Scanline Location Registers (Vertical)"],
                0x213E => ["STAT77", 0, "PPU Status Register"],
                0x213F => ["STAT78", 0, "PPU Status Register"],
                0x2140 => ["APUIO0", 0, "APU IO Registers"],
                0x2141 => ["APUIO1", 0, "APU IO Registers"],
                0x2142 => ["APUIO2", 0, "APU IO Registers"],
                0x2143 => ["APUIO3", 0, "APU IO Registers"],
                0x2180 => ["WMDATA", 0, "WRAM Data Register"],
                0x2181 => ["WMADDL", 0, "WRAM Address Registers"],
                0x2182 => ["WMADDM", 0, "WRAM Address Registers"],
                0x2183 => ["WMADDH", 0, "WRAM Address Registers"]
            }

            # Access method for reading/writing registers
            def self.access(operation, address, value = nil)
                register = REGISTER_MAP[address]
                if register
                    name, current_value, description = register
                    case operation
                    when :read
                        current_value
                    when :write
                        REGISTER_MAP[address] = [name, value, description]
                    else
                        raise "Unknown operation: #{operation}"
                    end
                else
                    raise "Invalid register address: 0x#{address.to_s(16)}"
                end
            end
        end
    end
end
