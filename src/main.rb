require_relative 'snes/console'
require 'logger'
require 'fileutils'

# rom_filepath = ARGV[0]
megaman_x_rom_filepath = "/mnt/c/Users/Alisson/dev/pessoal/mundau_snes/roms/Mega Man X (E).smc"
pacman_rom_filepath = "/mnt/c/Users/Alisson/dev/pessoal/mundau_snes/roms/pacman.smc"
dkc2_rom_filepath = "/mnt/c/Users/Alisson/dev/pessoal/mundau_snes/roms/Donkey Kong Country 2 - Diddy's Kong Quest (USA) (En,Fr).sfc"
tg3000_rom_filepath = "/mnt/c/Users/Alisson/dev/pessoal/mundau_snes/roms/DSP4/Planet's Champ TG 3000, The (Japan).sfc"
yoshi_rom_filepath = "/mnt/c/Users/Alisson/dev/pessoal/mundau_snes/roms/Super FX GSU-2/Super Mario World 2 - Yoshi's Island (Europe) (En,Fr,De) (Rev 1).sfc"
zelda_rom_filepath = "/mnt/c/Users/Alisson/dev/pessoal/mundau_snes/roms/Legend of Zelda, The - A Link to the Past (U) [!].smc"
chrono_trigger_rom_filepath = "/mnt/c/Users/Alisson/dev/pessoal/mundau_snes/roms/Chrono Trigger (U) [!].smc"
star_ocean_rom_filepath = "/mnt/c/Users/Alisson/dev/pessoal/mundau_snes/roms/S-DD1/Star Ocean (J) [!].smc"

def set_logger
    # logger = Logger.new(STDOUT)
    log_directory = 'log'
    FileUtils.mkdir_p(log_directory) unless Dir.exist?(log_directory)
    # Set up logger
    log_file = "#{log_directory}/snes.log"
    File.delete(log_file) if File.exist?(log_file)

    $logger = Logger.new(log_file)
    $logger.level = Logger::DEBUG
    $logger.formatter = proc do |severity, datetime, progname, msg|
        "#{severity} -- : #{msg}\n"
    end
end

set_logger

# console = Snes::Console.new(debug=true)
console = Snes::Console.new(debug=true)

console.insert_cartridge(megaman_x_rom_filepath) # LoRom
# console.insert_cartridge(pacman_rom_filepath) # LoRom
# console.insert_cartridge(dkc2_rom_filepath) # HiRom
# console.insert_cartridge(tg3000_rom_filepath)
# console.insert_cartridge(yoshi_rom_filepath)
# console.insert_cartridge(zelda_rom_filepath)
# console.insert_cartridge(chrono_trigger_rom_filepath)
# console.insert_cartridge(star_ocean_rom_filepath)

console.turn_on
console.print_cartridge_header

console.m_map.read(0x00FFC0) # The ROM header resides at the end of the first 32 KiB bank at $007FC0 in the ROM, mapped to $00FFC0 in memory.
console.m_map.read(0x00FFC1)
console.m_map.read(0x00FFC2)
console.m_map.read(0x00FFC3)
console.m_map.read(0x3FFFC3)


