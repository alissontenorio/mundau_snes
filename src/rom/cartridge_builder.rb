module ROM
    class CartridgeBuilder
        def initialize(raw_rom)
            rom = Rom::Cartridge.new
            rom.total_size = raw_rom.size
            rom.has_scm = has_scm_header(rom.total_size)
            rom.expected_checksum = calculate_checksum(raw_rom, rom.has_scm)
            rom.header_type = header_type(raw_rom, rom.has_scm)

            header_start_addr = Rom::Cartridge::MAP_MODES_START_ADDR_HEADER[rom.header_type.to_sym].to_i(16)
            header_contents = header_contents(raw_rom, header_start_addr)

            rom.cartridge_name = header_contents[:cartridge_name]
            rom.makeup_raw = header_contents[:makeup]
            rom.type_raw = header_contents[:rom_type]
            rom.rom_size_raw = header_contents[:rom_size]
            rom.sram_size_raw = header_contents[:sram_size]
            rom.country_code_raw = header_contents[:country_code]
            rom.developer_id_raw = header_contents[:developer_id]
            rom.version = header_contents[:rom_version]
            rom.checksum_complement = header_contents[:checksum_complement]
            rom.checksum = header_contents[:checksum]

            rom_types_mapper = Rom::Types.new(rom.type_raw)
            rom.co_processor = rom_types_mapper.co_processor if rom_types_mapper.has_co_processor
            rom.type = rom_types_mapper.rom_type

            rom_makeup = Rom::Makeup.new(rom.makeup_raw)
            rom.makeup_speed = rom_makeup.speed
            rom.makeup_map_mode = rom_makeup.map_mode

            rom.rom_size_in_kb = 1 << rom.rom_size_raw
            rom.sram_size_in_kb = 1 << rom.sram_size_raw

            rom.country_code = Rom::Country.new(rom.country_code_raw).country_code

            if has_expanded_header?(rom.developer_id_raw)
                expanded_header_start_addr = header_start_addr - 16
                ehc = expanded_header_contents(raw_rom, expanded_header_start_addr)
                rom.maker_code = ehc[:maker_code]
                rom.game_code = ehc[:game_code]
                rom.expansion_ram_size_raw = ehc[:expansion_ram_size]
                rom.expansion_ram_size_in_kb = 8 << ehc[:expansion_ram_size] if ehc[:expansion_ram_size].nonzero?
                rom.special_version = ehc[:special_version]
                rom.cartridge_type_sub_number = ehc[:cartridge_type_sub_number]
            end

            puts "rom info: #{rom.to_hash}"
            puts ""
        end

        # If developer id (fixed value) at FFD0 + 10 is 33 (in hex) it will have expanded header
        def has_expanded_header?(developer_id)
            Utils::BaseConverter.integer_to_hex(developer_id) == '33'
        end

        def expanded_header_contents(raw_rom, addr)
            # addr should be FFB0
            # Expanded cartridge header
            # $00:FFB0 	2 bytes 	Maker Code
            # $00:FFB2 	4 bytes 	Game Code
            # $00:FFB6 	7 bytes 	Fixed Value
            # $00:FFBD 	1 byte 	Expansion RAM Size
            # $00:FFBE 	1 byte 	Special Version
            # $00:FFBF 	1 byte 	Cartridge Type (Sub-number)
            {
                maker_code: raw_rom[addr, 2],
                game_code: raw_rom[addr+2, 4],
                # fixed_value: raw_rom[addr+6, 7].ord
                expansion_ram_size: raw_rom[addr+13].ord,
                special_version: raw_rom[addr+14].ord,
                cartridge_type_sub_number: raw_rom[addr+15].ord
            }
        end

        def header_contents(raw_rom, addr)
            {
                cartridge_name: raw_rom[addr, 21].strip,
                makeup: raw_rom[addr + 21].ord,
                rom_type: raw_rom[addr + 22],
                rom_size: raw_rom[addr + 23].ord,
                sram_size: raw_rom[addr + 24].ord,
                country_code: raw_rom[addr + 25].ord,
                developer_id: raw_rom[addr + 26].ord,
                rom_version: raw_rom[addr + 27].ord,
                checksum_complement: raw_rom[addr + 28, 2].ord,
                checksum: raw_rom[addr + 30, 2].ord
            }
        end

        # How do I recognize the ROM type?
        # https://en.wikibooks.org/wiki/Super_NES_Programming/SNES_memory_map
        def header_type(rom, has_scm)
            Rom::Cartridge::MAP_MODES_START_ADDR_HEADER.each do |header_type, header_start_addr|
                header_start_addr_decimal = header_start_addr.to_i(16)
                if header_match?(rom, header_start_addr_decimal, has_scm)
                    return header_type.to_s
                end
            end

            raise CartridgeHeaderTypeNotIdentifiedError()
        end

        def has_scm_header(size)
            size % 1024 != 0
        end

        def header_match?(rom, start_addr, has_scm)
            if has_scm # skip header if present
                start_addr += 512
            end
            checksum1 = rom[start_addr + 30].ord.to_s(16).force_encoding(Encoding::ASCII_8BIT)
            checksum1 = "0" * (2 - checksum1.size) + checksum1
            checksum2 = rom[start_addr + 31].ord.to_s(16).force_encoding(Encoding::ASCII_8BIT)
            checksum2 = "0" * (2 - checksum2.size) + checksum2
            checksum = checksum2 + checksum1

            csc1 = rom[start_addr + 28].ord.to_s(16).force_encoding(Encoding::ASCII_8BIT)
            csc1 = "0" * (2 - csc1.size) + csc1
            csc2 = rom[start_addr + 29].ord.to_s(16).force_encoding(Encoding::ASCII_8BIT)
            csc2 = "0" * (2 - csc2.size) + csc2
            checksum_complement = csc2 + csc1
            match_complement = (checksum.to_i(16) + checksum_complement.to_i(16) == 65535)
            match_complement
        end

        # The checksum is a 16-bit sum of all of the bytes in the ROM
        def calculate_checksum(raw_rom, has_scm)
            size = raw_rom.size
            addr = 0

            # skip header if present
            if has_scm
                addr = 512
            end

            sum = 0
            while addr < size
                sum += raw_rom[addr].ord
                addr = addr + 1
            end

            (sum & "FFFF".to_i(16)).to_s(16)
        end
    end
end