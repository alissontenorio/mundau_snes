require_relative 'cartridge/cartridge'
require_relative 'snes/cartridge_reader'

def open_rom(rom_filepath)
    file = File.open(rom_filepath, 'rb')
    b_array = file.read
    file.close
    b_array
end

# rom_filepath = ARGV[0]
rom_filepath = "/mnt/c/Users/Alisson/dev/pessoal/mundau_snes/roms/pacman.smc"
# rom_filepath = "../roms/Donkey Kong Country 2 - Diddy's Kong Quest (USA) (En,Fr).sfc"

rom = open_rom(rom_filepath)


cartridge = CartridgeReader.new(rom)
# Cartridge.new(rom)