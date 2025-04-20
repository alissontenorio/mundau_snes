module Snes
    module Memory
        class LoRomMemoryMapperBKP
            def initialize(cartridge, ram, sram)
                @rom = cartridge.rom_raw
                @ram = ram
                @sram = sram
            end

            ### Quadrante 1

            def read_first_bank_system(bank, offset)
                if offset.between?(0x0000, 0x1FFF)
                    read_low_ram(bank, offset) # WRAM # MEDIUM_CLOCK_SPEED
                elsif offset.between?(0x2000, 0x3FFF)
                    read_ppu(bank, offset) # PPU, etc # HIGH_CLOCK_SPEED
                elsif offset.between?(0x4000, 0x41FF)
                    read_joypad(bank, offset) # Controller, joystick, joypad # LOW_CLOCK_SPEED
                elsif offset.between?(0x4200, 0x5FFF)
                    # CPU, DMA, etc # HIGH_CLOCK_SPEED
                    raise NoMethodError.new("CPU, DMA, etc")
                elsif offset.between?(0x6000, 0x7FFF)
                    # Expand area / Enhancement Chips # MEDIUM_CLOCK_SPEED
                    raise NoMethodError.new("Expand area / Enhancement Chips")
                elsif offset.between?(0x8000, 0xFFFF)
                    read_rom_first_bank_system(bank, offset) # ROM # MEDIUM_CLOCK_SPEED
                else
                    raise "Error unknown reading memory"
                end
            end

            ### Quadrante 2

            def read_first_bank_rom(bank, offset)
                if bank.between?(0x60, 0x6F) && offset.between?(0x0000, 0x7FFF)
                    # DSP AREA
                    raise NoMethodError.new("DSP not implemented")
                    return
                elsif bank.between?(0x70, 0x7D) && offset.between?(0x0000, 0x7FFF)
                    return read_sram(bank, offset) # SRAM
                end

                read_rom_first_bank(bank, offset) # 0x40..0x7D ROM #MEDIUM_CLOCK_SPEED
            end

            def read_bank_ram(bank, offset)
                read_ram(bank, offset) # WRAM # MEDIUM_CLOCK_SPEED
            end

            ### Quadrante 3

            def read_second_bank_system(bank, offset)
                if offset.between?(0x0000, 0x1FFF)
                    read_low_ram(bank, offset) # WRAM # MEDIUM_CLOCK_SPEED
                elsif offset.between?(0x2000, 0x3FFF)
                    read_ppu(bank, offset) # PPU, etc # HIGH_CLOCK_SPEED
                elsif offset.between?(0x4000, 0x41FF)
                    read_joypad(bank, offset) # Controller, joystick, joypad # LOW_CLOCK_SPEED
                elsif offset.between?(0x4200, 0x5FFF)
                    # CPU, DMA, etc
                    raise NoMethodError.new("CPU, DMA, etc")
                elsif offset.between?(0x6000, 0x7FFF)
                    # Expand
                    raise NoMethodError.new("Expand area / Enhancement Chips")
                elsif offset.between?(0x8000, 0xFFFF)
                    # if (the value at address $420D (hardware register) is set to 1.)
                    #     HIGH_CLOCK_SPEED
                    # else
                    #     MEDIUM_CLOCK_SPEED
                    # end
                    read_rom_second_bank_system(bank, offset) # ROM # HIGH_CLOCK_SPEED AND MEDIUM_CLOCK_SPEED
                else
                    raise "Error unknown reading memory"
                end
            end

            ### Quadrante 4

            def read_second_bank_rom(bank, offset)
                read_rom_second_bank(bank, offset) # ROM # 0xC0..0xFF HIGH_CLOCK_SPEED AND MEDIUM_CLOCK_SPEED
            end

            ### Read specifics

            # Banks: 0x70, 0x7D, offset: 0x0000 ~ 0x7FFF
            def read_sram(bank, offset)
                first_sram_bank = 0x70
                sram_max_offset_pos = 0x8000
                sram_pos = offset + ((bank - first_sram_bank) * sram_max_offset_pos)
                @sram[sram_pos]
            end

            # Banks: 0x7E, 0x7F, offset: 0x0000 ~ 0xFFFF
            def read_ram(bank, offset)
                # puts "read_ram"
                # Positions map
                # 7E:0000 -> 0
                # 7E:FFFF -> 65_535
                # 7F:0000 -> 65_536
                # 7F:FFFF -> 131_071

                ram_pos = offset + (bank == 0x7F ? 0x10_000 : 0)
                # Low Ram, do something? if bank == 0x7E && offset < 2000

                @ram[ram_pos]
            end

            # Bank: systems, offset: 0x0000, 0x1FFF
            def read_low_ram(bank, offset)
                raise AddressOutOfRangeError("Should not be accessing this here") if (bank > 0x3F && bank < 0x7E) || (bank > 0xBF)
                raise AddressOutOfRangeError("Should not be accessing this here") if offset > 0x1FFF
                @ram[offset]
            end

            # Bank: systems, offset: 0x2000 ~ 0x3FFF
            def read_ppu(bank, offset)
                raise "ToDo"
            end

            # Bank: systems, offset: 0x4000 ~ 0x41FF
            def read_joypad(bank, offset)
                raise "ToDo"
            end

            # Read rom upper part from bank system
            # Banks   0x00 ~ 0x3F, offset: 0x8000 ~ 0xFFFF
            def read_rom_first_bank_system(bank, offset)
                # puts "read_rom_first_bank_system"
                # maps snes address to rom address
                # 04:8000 -> 02:0000
                # 05:8000 -> 02:8000
                # 06:8000 -> 03:0000
                # 07:8000 -> 03:8000

                rom_bank = bank >> 1
                if bank & 1 == 1 # odd
                    rom_offset = offset
                else # even
                    rom_offset = offset - 0x8000
                end

                rom_addr = "#{rom_bank.to_s(16)}#{rom_offset.to_s(16)}".to_i(16)
                @rom[rom_addr]
            end

            # Read rom upper part from bank system
            def read_rom_second_bank_system(bank, offset)
                # puts "read_rom_second_bank_system"
                rom_bank = bank >> 1
                if bank & 1 == 1 # odd
                    rom_offset = offset
                else # even
                    rom_offset = offset - 0x8000
                end

                rom_addr = "#{rom_bank.to_s(16)}#{rom_offset.to_s(16)}".to_i(16)
                @rom[rom_addr]
            end

            def read_rom_first_bank(bank, offset)
                # puts "read_rom_first_bank"
                raise AddressOutOfRangeError("Should not be accessing this here") if offset < 0x8000

                rom_bank = (bank - 0x40) >> 1
                if bank & 1 == 1 # odd
                    rom_offset = offset
                else # even
                    rom_offset = offset - 0x8000
                end
                rom_addr = "#{rom_bank.to_s(16)}#{rom_offset.to_s(16)}".to_i(16)
                @rom[0x200000 + rom_addr]
            end

            def read_rom_second_bank(bank, offset)
                raise "ToDo"
                @rom
            end
        end
    end
end

# 8000 (em hexa ) endereços * 40 -> 20 0000
# 64 bancos * 32 k (cada espaço) * 1024 (converter para bytes) -> 20 0000

# Bank system rom map example
# 32 * 8000
# 00:0000
# 00:8000
# 01:0000
# 01:8000
# 02:0000
# 02:8000
# 03:0000
# 03:8000
# 04:0000
# 04:8000
# 05:0000
# 05:8000
# 06:0000
# 06:8000
# 07:0000
# 07:8000
# 08:0000
# 08:8000
# 09:0000
# 09:8000
# 0A:0000
# 0A:8000
# 0B:0000
# 0B:8000
# 0C:0000
# 0C:8000
# 0D:0000
# 0D:8000
# 0E:0000
# 0E:8000
# 0F:0000
# 0F:8000
#
# 10:0000
# 10:8000
# 11:0000
# 11:8000
# 12:0000
# 12:8000
# 13:0000
# 13:8000
# 14:0000
# 14:8000
# 15:0000
# 15:8000
# 16:0000
# 16:8000
# 17:0000
# 17:8000
# 18:0000
# 18:8000
# 19:0000
# 19:8000
# 1A:0000
# 1A:8000
# 1B:0000
# 1B:8000
# 1C:0000
# 1C:8000
# 1D:0000
# 1D:8000
# 1E:0000
# 1E:8000
# 1F:0000
# 1F:8000