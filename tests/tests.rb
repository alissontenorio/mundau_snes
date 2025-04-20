# Tests access lorom
#
# Create test for this LoRom
#
# puts "ROM First Quadrant upper (first bank system)"
# # Access ROM First Quadrant upper
# @m_map.read(0x00FFC0) # The ROM header resides at the end of the first 32 KiB bank at $007FC0 in the ROM, mapped to $00FFC0 in memory.
# @m_map.read(0x00FFC1)
# @m_map.read(0x00FFC2)
# @m_map.read(0x00FFC3)
# @m_map.read(0x3FFFC3)
#
# puts "ROM Second Quadrant upper (first rom upper)"
# # Access ROM Second Quadrant upper
# @m_map.read(0x40FFC0)
# @m_map.read(0x41FFC0)
# @m_map.read(0x42FFC0)
# @m_map.read(0x43FFC0)

# Access RAM (WRAM Banks)
# puts "Access RAM (WRAM Banks)"
# puts @m_map.read(0x7E4FC0)
# puts @m_map.read(0x7EAFC0)
# puts @m_map.read(0x7F3FC0)
# puts @m_map.read(0x7FBFC0)
#
# # Access Low RAM 1
# puts @m_map.read(0x001FC0)
# puts @m_map.read(0x2010C0)
# puts @m_map.read(0x3010C0)
# puts @m_map.read(0x3F1FFF)
#
# # Access Low RAM 2
# puts @m_map.read(0x801FC0)
# puts @m_map.read(0x9010C0)
# puts @m_map.read(0xA010C0)
# puts @m_map.read(0xBF1FFF)
#
# Access SRAM
# @m_map.read(0x707FFF)
# @m_map.read(0x708000)
# @m_map.read(0x701FC0)
# @m_map.read(0x701FC0)
# @m_map.read(0x702FC0)
# @m_map.read(0x705FC0)
# @m_map.read(0x707FFF)
# @m_map.read(0x7D1FC0)
# @m_map.read(0x7D2FC0)
# @m_map.read(0x7D5FC0)
# @m_map.read(0x7D7FFF)




# Test bank reading
# begin
#     console.m_map.read(0x101000) # bank system, low ram
#     console.m_map.read(0xE16000) # bank rom, read rom
#     console.m_map.read(0x7D0100) # lorom -> bank rom, read sram - hirom -> bank rom, read rom
#     console.m_map.read(0x7E0100) # bank ram, low ram
#     console.m_map.read(0x7E7000) # bank ram, read ram
#     console.m_map.read(0x7F0100) # bank ram, read ram
#     console.m_map.read(0x203000) # bank system, read ppu
#     console.m_map.read(0x234111) # bank system, read controller
#     console.m_map.read(0x255000) # bank system, read cpu
#     console.m_map.read(0x2F6000) # bank system, expansion
#     console.m_map.read(0x3E6000) # hirom -> bank system, expansion, read sram - lorom -> bank system, expansion
#     console.m_map.read(0x30F000) # bank system, Read rom
#     console.m_map.read(0x434000) # bank rom, Read rom
#     console.m_map.read(0x459001) # bank rom, Read rom
#     console.m_map.read(0x723000) # hirom -> bank rom, read rom - lorom -> bank rom, read sram
# rescue => e
#     $logger.error("Caught exception: #{e.class} - #{e.message}")
#     $logger.error("Backtrace: #{e.backtrace.join("\n")}")
# end