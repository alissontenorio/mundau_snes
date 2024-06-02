class CartridgeReader
    LO_ROM_HEADER = "007FC0"
    HI_ROM_HEADER = "00FFC0"
    EX_HI_ROM_HEADER = "40FFC0"

    def initialize(rom)
        size = rom.size
        has_scm = has_scm_header(size)
        expected_checksum = compute_checksum(rom, size, has_scm)
        header_type = header_type(rom, has_scm)
        start_addr = eval(header_type).to_i(16) # ToDo: improve call to header type
        header_contents = header_contents(rom, start_addr)
        # cartridge = Cartridge.new
    end

    def header_contents(rom, addr)
        name = rom[addr, 21]
        makeup = rom[addr + 21]
        rom_type  = rom[addr + 22]
        rom_size  = rom[addr + 23]
        sram_size = rom[addr + 24]

        puts "name #{name}"
        puts "makeup #{makeup.ord}"
        puts "rom_type #{rom_type.ord}"
        puts "rom_size #{rom_size.ord}"
        puts "sram_size #{sram_size.ord}"
    end

    def header_type(rom, has_scm)
        addr = (LO_ROM_HEADER).to_i(16)
        return "LO_ROM_HEADER" if header_match?(rom, addr, has_scm)
        addr = (HI_ROM_HEADER).to_i(16)
        return "HI_ROM_HEADER" if header_match?(rom, addr, has_scm)
        addr = (EX_HI_ROM_HEADER).to_i(16)
        return "EX_HI_ROM_HEADER" if header_match?(rom, addr, has_scm)
        # ToDo: improve exception
        raise Exception("Couldn't check header type")
    end


    def has_scm_header(size)
        size % 1024 != 0
    end

    # hex to integer
    # "0A".to_i(16) #=>10
    # "\x80".force_encoding(Encoding::ASCII_8BIT).ord -> 128
    #
    # integer to hex
    # 10.to_s(16) #=> "a"
    # 128.chr -> "\x80"
    #
    #
    # 0x8f.chr -> "\x8F"
    #
    # x = 0x8f ; puts x.class # prints 128
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
    def compute_checksum(rom, size, has_scm)
        addr = 0

        # skip header if present
        if has_scm
            addr = 512
        end

        sum = 0
        while addr < size
            sum += rom[addr].ord # "a".ord # => 97
            addr = addr + 1
        end

        (sum & "FFFF".to_i(16)).to_s(16)
    end
end