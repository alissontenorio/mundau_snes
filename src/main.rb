require_relative 'cartridge/cartridge'
require_relative 'snes/cartridge_header/cartridge_reader'

def open_rom(rom_filepath)
    file = File.open(rom_filepath, 'rb')
    b_array = file.read
    file.close
    b_array
end

# rom_filepath = ARGV[0]
pacman_rom_filepath = "/mnt/c/Users/Alisson/dev/pessoal/mundau_snes/roms/pacman.smc"
dkc2_rom_filepath = "/mnt/c/Users/Alisson/dev/pessoal/mundau_snes/roms/Donkey Kong Country 2 - Diddy's Kong Quest (USA) (En,Fr).sfc"
tg3000_rom_filepath = "/mnt/c/Users/Alisson/dev/pessoal/mundau_snes/roms/DSP4/Planet's Champ TG 3000, The (Japan).sfc"
yoshi_rom_filepath = "/mnt/c/Users/Alisson/dev/pessoal/mundau_snes/roms/Super FX GSU-2/Super Mario World 2 - Yoshi's Island (Europe) (En,Fr,De) (Rev 1).sfc"

pacman_rom = open_rom(pacman_rom_filepath)
dkc2_rom_rom = open_rom(dkc2_rom_filepath)
tg3000_rom = open_rom(tg3000_rom_filepath)
yoshi_rom = open_rom(yoshi_rom_filepath)


cartridge = SNES::CartridgeReader.new(pacman_rom)
cartridge = SNES::CartridgeReader.new(dkc2_rom_rom)
cartridge = SNES::CartridgeReader.new(tg3000_rom)
cartridge = SNES::CartridgeReader.new(yoshi_rom)