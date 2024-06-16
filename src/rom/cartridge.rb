require_relative 'header/rom_types'
require_relative 'header/makeup'
require_relative 'header/country'

module Rom
    class Cartridge
        MAP_MODES = %w[LO_ROM HI_ROM EX_HI_ROM]
        MAP_MODES_START_ADDR_HEADER = {
            LO_ROM_HEADER: "007FC0",
            HI_ROM_HEADER: "00FFC0",
            EX_HI_ROM_HEADER: "40FFC0"
        }

        attr_accessor :total_size, :has_scm, :expected_checksum, :header_type, :makeup_raw, :type_raw, :type,
                      :rom_size_raw, :sram_size_raw, :country_code_raw, :developer_id_raw, :version,
                      :checksum_complement, :checksum, :co_processor, :cartridge_name, :rom_size_in_kb,
                      :sram_size_in_kb, :country_code, :developer_id, :makeup_speed, :makeup_map_mode,
                      :maker_code, :game_code, :expansion_ram_size_raw, :special_version, :cartridge_type_sub_number,
                      :expansion_ram_size_in_kb

        def initialize
            @total_size = nil
            @has_scm = nil
            @expected_checksum = nil

            # ROM Header - https://snes.nesdev.org/wiki/ROM_header
            # LO_ROM, HI_ROM, ETC
            @header_type = nil

            # Game Title Registration
            # more info in ..images/rom/game_title_registration.png
            @cartridge_name = nil

            # Map Mode
            # ROM speed and memory map mode (LoROM/HiROM/ExHiROM)
            @makeup_raw = nil
            @makeup_speed = nil
            @makeup_map_mode = nil

            # Cartridge Type
            # Chipset (Indicates if a cartridge contains extra RAM, a battery, and/or a coprocessor)
            @type_raw = nil
            @type = nil
            @co_processor = nil

            # ROM Size
            # 1<<N kilobytes, rounded up (so 8=256KB, 12=4096KB and so on)
            @rom_size_raw = nil
            @rom_size_in_kb = nil

            # RAM Size
            # 1<<N kilobytes (so 1=2KB, 5=32KB, and so on)
            @sram_size_raw = nil
            @sram_size_in_kb = nil

            # Destination Code
            # Implies NTSC/PAL
            @country_code_raw = nil
            @country_code = nil

            # Fixed Value
            # When its set to 33 indicates expanded header presence
            @developer_id_raw = nil

            # Mask ROM Version
            # 0 = first
            @version = nil

            # Complement Check
            @checksum_complement = nil # Checksum ^ $FFFF

            # Checksum
            @checksum = nil

            # Expanded Header
            @maker_code = nil
            @game_code = nil

            # If the size is not listed below use next larger
            # 0 -> None
            # 1 -> 16 KBit
            # 3 -> 64 KBit
            # 5 -> 256 KBit
            # 6 -> 512 KBit
            # 7 -> 1 Mbit
            @expansion_ram_size_raw = nil
            @expansion_ram_size_in_kb = nil

            @special_version = nil
            @cartridge_type_sub_number = nil

            # Detecting SA-1 chip
            # if read1($00ffd5) == $23
            #     !sa1 = 1
            # endif
            #
            # if Utils::HexIntegerBinaryConverter::binary_to_hex(makeup_bin) == 23
            #     # Uses chip 21
            # end

            # Interrupt vectors
        end

        def to_hash
            instance_variables.map do |var|
                [var[1..-1].to_sym, instance_variable_get(var)]
            end.to_h
        end
    end
end