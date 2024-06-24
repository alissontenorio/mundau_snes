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