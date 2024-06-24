module Snes
    module Memory
        class HiRomMemoryMapper
            def initialize(cartridge, ram, sram)
                @rom = cartridge.rom_raw
                @ram = ram
                @sram = sram
            end

            def read_sram(bank, offset)

            end

            def read_ram(bank, offset)

            end

            def read_ppu(bank, offset)

            end

            def read_joypad(bank, offset)

            end

            def read_rom_first_bank_system(bank, offset)
                @rom
            end

            def read_rom_second_bank_system(bank, offset)
                @rom
            end

            def read_rom_first_bank(bank, offset)
                @rom
            end

            def read_rom_second_bank(bank, offset)
                @rom
            end

            def read_first_bank_system(bank, offset)
                if offset.between?(0x0000, 0x1FFF)
                    read_ram(bank, offset) # WRAM # MEDIUM_CLOCK_SPEED
                elsif offset.between?(0x2000, 0x3FFF)
                    read_ppu(bank, offset) # PPU, etc # HIGH_CLOCK_SPEED
                elsif offset.between?(0x4000, 0x41FF)
                    read_joypad(bank, offset) # Controller, joystick, joypad # LOW_CLOCK_SPEED
                elsif offset.between?(0x4200, 0x5FFF)
                    # CPU, DMA, etc # HIGH_CLOCK_SPEED
                    raise NoMethodError.new("CPU, DMA, etc")
                elsif offset.between?(0x6000, 0x7FFF)
                    # Expand area / Enhancement Chips / SRAM # MEDIUM_CLOCK_SPEED
                    if bank.between?(0x00, 0x0F)
                        raise NoMethodError.new("DSP not implemented") if bank.between?(0x00, 0x0F)
                    elsif bank.between?(0x20, 0x3F)
                        # Estou seguindo o que varias pessoas comentaram sobre o endereçamento da SRAM, mas
                        # na documentação oficial do snes diz que a SRAM para HiRom fica entre 0x30 ~ 0x3F

                        read_sram(bank, offset) # SRAM
                    end
                elsif offset.between?(0x8000, 0xFFFF)
                    read_rom_first_bank_system(bank, offset)# ROM # MEDIUM_CLOCK_SPEED
                else
                    raise "Error unknown reading memory"
                end
            end

            def read_second_bank_system(bank, offset)
                if offset.between?(0x0000, 0x1FFF)
                    read_ram(bank, offset) # WRAM # MEDIUM_CLOCK_SPEED
                elsif offset.between?(0x2000, 0x3FFF)
                    read_ppu(bank, offset) # PPU, etc # HIGH_CLOCK_SPEED
                elsif offset.between?(0x4000, 0x41FF)
                    read_joypad(bank, offset) # Controller, joystick, joypad # LOW_CLOCK_SPEED
                elsif offset.between?(0x4200, 0x5FFF)
                    # CPU, DMA, etc
                    raise NoMethodError.new("CPU, DMA, etc")
                elsif offset.between?(0x6000, 0x7FFF)
                    # Expand area / Enhancement Chips / SRAM # MEDIUM_CLOCK_SPEED
                    raise NoMethodError.new("DSP not implemented") if bank.between?(0x80, 0x8F)
                    raise NoMethodError.new("Enhancement Chips / SRAM not implemented")
                elsif offset.between?(0x8000, 0xFFFF)
                    # if (the value at address $420D (hardware register) is set to 1.)
                    #     HIGH_CLOCK_SPEED
                    # else
                    #     MEDIUM_CLOCK_SPEED
                    # end
                    read_rom_second_bank_system(bank, offset, 'second_bank_system') # ROM # HIGH_CLOCK_SPEED AND MEDIUM_CLOCK_SPEED
                else
                    raise "Error unknown reading memory"
                end
            end

            def read_first_bank_rom(bank, offset)
                read_rom_first_bank(bank, offset) # ROM # 0x40..0x7D  MEDIUM_CLOCK_SPEED
            end

            def read_second_bank_rom(bank, offset)
                # 0xC0..0xFF
                # HIGH_CLOCK_SPEED or MEDIUM_CLOCKSPEED
                read_rom_second_bank(bank, offset) # ROM # HIGH_CLOCK_SPEED AND MEDIUM_CLOCK_SPEED
            end

            def read_bank_ram(bank, offset)
                read_ram(bank, offset) # WRAM # MEDIUM_CLOCK_SPEED
            end
        end
    end
end