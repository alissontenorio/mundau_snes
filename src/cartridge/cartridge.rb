require_relative 'header/rom_type'
require_relative 'header/map_mode'
require_relative 'header/country'
require_relative 'header/cpu_vectors'

module Rom
    class Cartridge
        MAP_MODES = %w[LO_ROM HI_ROM EX_HI_ROM]
        MAP_MODES_START_ADDR_HEADER = {
            LO_ROM_HEADER: "007FC0",
            HI_ROM_HEADER: "00FFC0",
            EX_HI_ROM_HEADER: "40FFC0"
        }

        attr_accessor :cartridge_name, :rom_raw, :total_size, :has_scm, :expected_checksum, :header_type, :map_mode_raw, :type_raw, :type,
                      :rom_size_raw, :sram_size_raw, :country_code_raw, :developer_id_raw, :version,
                      :checksum_complement, :checksum, :co_processor, :rom_size_in_kb,
                      :sram_size_in_kb, :country_code, :developer_id, :map_mode_speed, :map_mode_map_mode,
                      :maker_code, :game_code, :expansion_ram_size_raw, :special_version, :cartridge_type_sub_number,
                      :expansion_ram_size_in_kb, :native_vectors, :emulation_vectors

        def initialize
            # Game Title Registration
            # more info in ..images/rom/game_title_registration.png
            @cartridge_name = nil

            @total_size = nil
            @has_scm = nil
            @expected_checksum = nil

            @rom_raw = nil

            # ROM Header - https://snes.nesdev.org/wiki/ROM_header
            # LO_ROM, HI_ROM, ETC
            @header_type = nil

            # Map Mode
            # ROM speed and memory map mode (LoROM/HiROM/ExHiROM)
            # ||____________________MapMode:
            # |                     $XO = LoROM/32K Banks            (Mode 20)
            # |                     $X1 = HiROM/64K Banks            (Mode 21)
            # |                     $X2 = LoROM/32K Banks + S-DD1    (Mode 22 Mappable)
            # Speed                 $X3 = LoROM/32K Banks + SA-1     (Mode 23 Mappable)
            # $2X = SlowROM (200ns) $X5 = HiROM/64K Banks            (Mode 25 ExHiROM)
            # $3X = FastROM (120ns) $XA = HiROM/64K Banks + SPC7110  (Mode 2A Mappable)
            @map_mode_raw = nil
            @map_mode_speed = nil
            @map_mode_map_mode = nil

            # Cartridge Type
            # Chipset (Indicates if a cartridge contains extra RAM, a battery, and/or a coprocessor)
            @type_raw = nil
            @type = nil
            @co_processor = nil

            # ROM Size
            # 1<<N kilobytes, rounded up (so 8=256KB, 12=4096KB and so on)
            # 09 ->  3 ~  4 MBit |  384 KBytes ~ 512 KBytes
            # 0A ->  5 ~  8 MBit | 5120 KBytes ~   1 MBytes
            # 0B ->  9 ~ 16 MBit | 1152 KBytes ~   2 MBytes
            # 0C -> 17 ~ 32 MBit | 2176 KBytes ~   4 MBytes
            # 0D -> 33 ~ 64 MBit | 4224 KBytes ~   9 MBytes
            @rom_size_raw = nil
            @rom_size_in_kb = nil # Stored in KBytes

            # RAM Size
            # 1<<N kilobytes (so 1=2KB, 5=32KB, and so on)
            # 00 ->   No RAM
            # 01 ->  16 KBit
            # 03 ->  64 KBit
            # 05 -> 256 KBit
            # 06 -> 512 KBit
            # 07 ->   1 MBit
            @sram_size_raw = nil
            @sram_size_in_kb = nil # Stored in KBytes

            # Destination Code
            # Implies NTSC/PAL
            @country_code_raw = nil
            @country_code = nil

            # Fixed Value
            # 00 = None
            # 01 = Nintendo
            # 33 = New (Uses Extended Header)
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
            # 0 ->  None
            # 1 ->  16 KBit |   1 KBytes
            # 3 ->  64 KBit |   8 KBytes
            # 5 -> 256 KBit |  32 KBytes
            # 6 -> 512 KBit |  64 KBytes
            # 7 ->   1 Mbit | 128 KBytes
            @expansion_ram_size_raw = nil
            @expansion_ram_size_in_kb = nil # Stored in KBytes

            # This is only used under special circumstances, such as for a promotional event.
            # The code 00H should be entered under normal circumstances.
            @special_version = nil

            # This is only assigned when it is necessary to distinguish between games which use the same cartridge type.
            # The code 00H is normally assigned.
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
            @native_vectors = nil
            @emulation_vectors = nil
        end

        def cartridge_type
            # LoRom
            # HiRom
            # others
            map_mode_map_mode[0]
        end

        # Debug purposes
        def print
            require 'json'
            puts JSON.pretty_generate(self.to_hash.except(:rom_raw))
        end

        def to_hash
            instance_variables.map do |var|
                [var[1..-1].to_sym, instance_variable_get(var)]
            end.to_h
        end
    end
end