require_relative 'snes/console'
require 'logger'
require 'fileutils'
require_relative 'utils/file'
require_relative 'interface/app'

extend Utils::FileOperations

debug = ARGV[0] != "nd"
megaman_x_rom_filepath = "/mnt/c/Users/Alisson/dev/pessoal/mundau_snes/roms/Mega Man X (E).smc"
pacman_rom_filepath = "/mnt/c/Users/Alisson/dev/pessoal/mundau_snes/roms/pacman.smc"
dkc2_rom_filepath = "/mnt/c/Users/Alisson/dev/pessoal/mundau_snes/roms/Donkey Kong Country 2 - Diddy's Kong Quest (USA) (En,Fr).sfc"
tg3000_rom_filepath = "/mnt/c/Users/Alisson/dev/pessoal/mundau_snes/roms/DSP4/Planet's Champ TG 3000, The (Japan).sfc"
yoshi_rom_filepath = "/mnt/c/Users/Alisson/dev/pessoal/mundau_snes/roms/Super FX GSU-2/Super Mario World 2 - Yoshi's Island (Europe) (En,Fr,De) (Rev 1).sfc"
zelda_rom_filepath = "/mnt/c/Users/Alisson/dev/pessoal/mundau_snes/roms/Legend of Zelda, The - A Link to the Past (U) [!].smc"
chrono_trigger_rom_filepath = "/mnt/c/Users/Alisson/dev/pessoal/mundau_snes/roms/Chrono Trigger (U) [!].smc"
star_ocean_rom_filepath = "/mnt/c/Users/Alisson/dev/pessoal/mundau_snes/roms/S-DD1/Star Ocean (J) [!].smc"

def set_logger
    log_directory = File.join(__dir__, '..', 'log')

    FileUtils.mkdir_p(log_directory) unless Dir.exist?(log_directory)

    # Set up log file
    log_file = "#{log_directory}/snes.log"
    File.delete(log_file) if File.exist?(log_file)

    # Create logger that writes to file
    # $cpu_logger = Logger.new(STDOUT)
    $cpu_logger = Logger.new(log_file)
    $cpu_logger.level = Logger::DEBUG

    # Custom log message format
    $cpu_logger.formatter = proc do |severity, datetime, progname, msg|
        "#{severity} -- : #{msg}\n"
    end

    # Ensure flushing of logs after each log entry
    $cpu_logger.instance_variable_get(:@logdev).dev.sync = true

    # APU-specific logger
    apu_log_file = "#{log_directory}/apu.log"
    File.delete(apu_log_file) if File.exist?(apu_log_file)
    $apu_logger = Logger.new(apu_log_file)
    $apu_logger.level = Logger::DEBUG
    $apu_logger.formatter = proc do |severity, datetime, progname, msg|
        "#{severity} -- : #{msg}\n"
    end
    $apu_logger.instance_variable_get(:@logdev).dev.sync = true

    # APU-specific logger
    ppu_log_file = "#{log_directory}/ppu.log"
    File.delete(ppu_log_file) if File.exist?(ppu_log_file)
    $ppu_logger = Logger.new(ppu_log_file)
    $ppu_logger.level = Logger::DEBUG
    $ppu_logger.formatter = proc do |severity, datetime, progname, msg|
        "#{severity} -- : #{msg}\n"
    end
    $ppu_logger.instance_variable_get(:@logdev).dev.sync = true
end

set_logger

# rom_raw = open_rom(pacman_rom_filepath) # LoRom
# rom_raw = open_rom(dkc2_rom_filepath) # HiRom
# rom_raw = open_rom(tg3000_rom_filepath)
# rom_raw = open_rom(yoshi_rom_filepath)
rom_raw = open_rom(zelda_rom_filepath)
# rom_raw = open_rom(megaman_x_rom_filepath)

puts "Turning on the console" if debug

console = Snes::Console.instance
console.setup(debug=debug)
console.insert_cartridge(rom_raw)
# console.print_cartridge_header

emulator_thread = Thread.new {
    app = Interface::EmulatorApp.new(console)
    app.create
    app.run
}
emulator_thread.abort_on_exception = true

# if debug
#     class Integer
#         def to_s
#             "0x%06X" % self  # Hexadecimal with zero-padding to 6 digits
#         end
#     end
# end

console.turn_on

emulator_thread.join
