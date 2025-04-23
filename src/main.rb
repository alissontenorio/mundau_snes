require_relative 'snes/console'
require 'logger'
require 'fileutils'
require_relative 'utils/file'
require_relative 'cartridge/cartridge'
require_relative 'cartridge/cartridge_builder'

extend Utils::FileOperations

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
    log_directory = 'log'
    FileUtils.mkdir_p(log_directory) unless Dir.exist?(log_directory)
    # Set up logger
    log_file = "#{log_directory}/snes.log"
    File.delete(log_file) if File.exist?(log_file)

    # $logger = Logger.new(STDOUT)
    $logger = Logger.new(log_file)
    $logger.level = Logger::DEBUG
    $logger.formatter = proc do |severity, datetime, progname, msg|
        "#{severity} -- : #{msg}\n"
    end
end

set_logger

# console = Snes::Console.new(debug=true)
console = Snes::Console.new(debug=true)

# console.insert_cartridge(pacman_rom_filepath) # LoRom
# console.insert_cartridge(dkc2_rom_filepath) # HiRom
# console.insert_cartridge(tg3000_rom_filepath)
# console.insert_cartridge(yoshi_rom_filepath)
rom_raw = open_rom(zelda_rom_filepath)
# console.insert_cartridge(chrono_trigger_rom_filepath)
# console.insert_cartridge(star_ocean_rom_filepath)
# rom_raw = open_rom(megaman_x_rom_filepath) # lorom fast
cartridge = Rom::CartridgeBuilder.new(rom_raw).get_cartridge
console.insert_cartridge(cartridge)
console.turn_on
console.print_cartridge_header

puts cartridge.emulation_vectors[:reset]
# Since its lorom, the bank should be x00
puts console.m_map.read(0x00_8000).ord.to_s(16)

# // On RESET
# cpu.E = 1;               // Emulation mode
# cpu.PB = 0x00;           // Program Bank
# cpu.SP = 0x01FF;         // Stack pointer
# cpu.setFlags({ I: true }); // Disable IRQ
#
# // Read reset vector from $FFFC-$FFFD
# const lo = memory.read(0xFFFC);
# const hi = memory.read(0xFFFD);
# cpu.PC = (hi << 8) | lo; // Should be 0x8000


# LO_ROM_HEADER = 0x80_FFC0 # lorom header
# LO_ROM_MIRROR_HEADER = 0x00_FFC0 # lorom mirror header
# LO_ROM_HEADER_LAST = 0xFF_FFFF # lorom header
# LO_ROM_MIRROR_HEADER_LAST = 0x7D_FFFF # lorom mirror header
#
#
# HI_ROM_HEADER = 0xC0_FFC0 # hirom header
# HI_ROM_MIRROR_HEADER = 0x01_FFC0 # hirom header
# HI_ROM_FIRST_MIRROR_HEADER_FIRST = 0x00_8000 # lorom header
# HI_ROM_SECOND_MIRROR_HEADER_FIRST = 0x80_8000 # lorom header
# HI_ROM_FIRST_MIRROR_HEADER_LAST = 0x3F_FFFF # lorom header
# HI_ROM_HEADER_LAST = 0xFF_FFFF # lorom header
# HI_ROM_MIRROR_HEADER_LAST = 0xBF_FFFF # lorom mirror header -> 3F FFFF

# puts console.m_map.read(LO_ROM_HEADER) # Deve retornar 7fc0
# puts console.m_map.read(LO_ROM_MIRROR_HEADER) # Deve retornar 7fc0
# puts console.m_map.read(LO_ROM_HEADER_LAST) # Deve retornar 3fffff
# puts console.m_map.read(LO_ROM_MIRROR_HEADER_LAST) # Deve retornar 3effff

# console.turn_off
# console.remove_cartridge


# start = HI_ROM_MIRROR_HEADER
# length = 21
# title = ""
# console.insert_cartridge(dkc2_rom_filepath) # HiRom
# console.turn_on
# puts console.m_map.read(HI_ROM_HEADER) # Deve retornar ffc0
# puts console.m_map.read(HI_ROM_MIRROR_HEADER) # Deve retornar ffc0
# puts console.m_map.read(HI_ROM_HEADER_LAST) # Deve retornar 3F FFFF
# puts console.m_map.read(HI_ROM_MIRROR_HEADER_LAST) # Deve retornar 3F FFFF
# puts console.m_map.read(HI_ROM_FIRST_MIRROR_HEADER_FIRST) # Deve retornar 00 0000
# puts console.m_map.read(HI_ROM_SECOND_MIRROR_HEADER_FIRST) # Deve retornar 20 0000
# puts console.m_map.read(HI_ROM_FIRST_MIRROR_HEADER_LAST) # Deve retornar 1F FFFF

# begin
#     (start...(start + length)).each { |addr|
#         # $logger.debug(addr)
#         title += console.m_map.read(addr)
#         $logger.debug("")
#     }
# rescue => e
#     $logger.error("Caught exception: #{e.class} - #{e.message}")
#     $logger.error("Backtrace: #{e.backtrace.join("\n")}")
# end
#
# $logger.debug(title)
