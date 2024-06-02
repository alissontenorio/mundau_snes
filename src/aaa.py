import sys

def open_as_byte_array(rom_name):
    file = open(rom_name, 'rb')
    b_array = bytearray(file.read())
    file.close()
    return b_array

LO_ROM_HEADER = "007FC0"
HI_ROM_HEADER = "00FFC0"

class ROMHeader(object):
    def __init__(self, rom_byte_array):
        self.file_size = len(rom_byte_array) # size in byte
        self.has_SCM = self.file_size % 1024 != 0
#         self.checksum(rom_byte_array)
        self.addr = self.compute_header_start(rom_byte_array)
        self.parse_header(rom_byte_array, self.addr)
#         self.addr = self.compute_header_start(rom_byte_array)
#         self.parse_header(rom_byte_array, self.addr)
#         self.parse_header_interrups(rom_byte_array, self.addr)
#         print(self.file_size)
#         print(self.has_SCM)
#         print(xxx)

    def compute_checksum(self, rom_byte_array):
        print("starting")
        addr = 0
        if self.has_SCM: # skip header if present
            addr = 512
        sum = 0

        print("file size")
        print(self.file_size)
        while addr < self.file_size:
            sum += rom_byte_array[addr]
            addr = addr + 1

        self.expected_checksum = hex(sum & int("FFFF", 16))

    def compute_header_start(self, rom_byte_array):
        self.compute_checksum(rom_byte_array)
        addr = int(LO_ROM_HEADER, 16)
        if self.__does_header_match(rom_byte_array, addr):
            if self.has_SCM:
                return addr + 512
            return addr
        addr = int(HI_ROM_HEADER, 16)
        if self.__does_header_match(rom_byte_array, addr):
            if self.has_SCM:
                return addr + 512
            return addr
        raise Exception("Error: can not find ROM header")

    def __does_header_match(self, rom_byte_array, start_addr):
            if self.has_SCM: # skip header if present
                start_addr += 512
            cs1 = hex(rom_byte_array[start_addr + 30])[2:]
            cs1 = (2 - len(cs1)) * "0" + cs1
            cs2 = hex(rom_byte_array[start_addr + 31])[2:]
            cs2 = (2 - len(cs2)) * "0" + cs2

            checksum = cs2 + cs1
            csc1 = hex(rom_byte_array[start_addr + 28])[2:]
            csc1 = (2 - len(csc1)) * "0" + csc1
            csc2 = hex(rom_byte_array[start_addr + 29])[2:]
            csc2 = (2 - len(csc2)) * "0" + csc2
            checksum_complement = csc2 + csc1

            match_complement = (int(checksum, 16) + int(checksum_complement, 16) == 65535)
            print(f"match {match_complement}")
            return match_complement

    def parse_header(self, rom_byte_array, start_address):
        addr = start_address
        self.name      = rom_byte_array[addr:addr + 21]
        self.makeup    = rom_byte_array[addr + 21]
        self.rom_type  = rom_byte_array[addr + 22]
        self.rom_size  = rom_byte_array[addr + 23]
        self.sram_size = rom_byte_array[addr + 24]
        self.licence_code = self.get_two_bytes_little_endian(rom_byte_array[addr + 25], rom_byte_array[addr + 26])
        self.version = rom_byte_array[addr + 27]
        self.checksum_complement = self.get_two_bytes_little_endian(rom_byte_array[addr + 28], rom_byte_array[addr + 29])
        self.checksum = self.get_two_bytes_little_endian(rom_byte_array[addr + 30], rom_byte_array[addr + 31])

        print("name")
        print(self.name)
        print(self.makeup)
        print("rom type")
        print(self.rom_type)

        print("size")
        print(self.rom_size)
        print(self.sram_size)

    def get_two_bytes_little_endian(self, byte0, byte1):
        b0 = hex(byte0)[2:]
        b0 = (2 - len(b0)) * "0" + b0
        b1 = hex(byte1)[2:]
        b1 = (2 - len(b1)) * "0" + b1
        return  int(b1 + b0, 16)

    def checksum(self, rom, fileout=None):
        addr = 0x7FDC

        assert(addr >= 0)
#         rom = bytearray(open(filein,"rb").read())
#         print("ROM: %s" % filein)
        print("SIZE: %dk + %d bytes" % (len(rom)//1024,len(rom)%1024))
        truncate = len(rom)
        # find power of 1 for first "half" of ROM
        rs0 = 32 * 1024
        rs1 = 0

        print(f"rs0: {rs0}")

        while (rs0 * 2) <= len(rom):
            rs0 *= 2

        print(f"rs0: {rs0}")
        print(f"lenrom {len(rom)}")
        if rs0 != len(rom): # second "half" of mixed size
            rs1 = 32 * 1024
            while (rs0 + (rs1 * 2)) <= len(rom):
                rs1 *= 2
            if (rs0 + rs1) != len(rom):
                print("ROM size must be sum of two powers of 2 larger than 32k!")
                sys.exit(2)
            print("SPLIT: %dk + %d bytes / %dk + %d bytes" % (rs0//1024,rs0%1024,rs1//1024,rs1%1024))
            while rs1 < rs0:
                rom.extend(rom[-rs1:])
                rs1 *= 2
            print("DUPLICATED: %dk + %d bytes" % (len(rom)//1024,len(rom)%1024))



        # erase existing checksum
        rom[addr+0] = 0x00
        rom[addr+1] = 0x00
        rom[addr+2] = 0xFF
        rom[addr+3] = 0xFF
        # compute
        cs = 0x0000
        for i in range(len(rom)):
            cs = (cs + rom[i+0]) & 0xFFFF
        print("CHECKSUM: $%04X" % cs)
        rom[addr+2] = cs & 0xFF
        rom[addr+3] = cs >> 8
        rom[addr+0] = rom[addr+2] ^ 0xFF
        rom[addr+1] = rom[addr+3] ^ 0xFF

        # verify
        cs2 = 0x0000
        for i in range(len(rom)):
            cs2 = (cs2 + rom[i+0]) & 0xFFFF
        assert(cs == cs2)



ROM = open_as_byte_array("../roms/pacman.smc")
header = ROMHeader(ROM)