require_relative '../../exceptions/cpu_exceptions'

module Snes
    module Memory
        class MemoryRange
            BANK = 0x00..0xFF
            OFFSET = 0x0000..0xFFFF

            BANKS = {
                system: [0x00..0x3F, 0x80..0xBF],
                rom: [0x40..0x7D, 0xC0..0xFF],
                ram: [0x7E..0x7F]
            }

            # usage BANK_SYSTEM_OFFSET_RANGES[:ppu].include?(offset)
            BANK_SYSTEM_OFFSET = {
                low_ram:      0x0000..0x1FFF,
                ppu:          0x2100..0x213F,
                apu:          0x2140..0x217F,
                wram:         0x2180..0x2183,
                controller:   0x4000..0x41FF,
                internal_cpu: 0x4200..0x42FF,
                dma:          0x4300..0x43FF,
                expansion:    0x6000..0x7FFF,
                rom:          0x8000..0xFFFF
            }

            BANK_RAM = {
                low_ram: {
                    bank: 0x7E,
                    offset: 0x0000..0x1FFF
                }
            }

            SRAM = {
                lorom: {
                    bank: 0x70..0x7D,
                    offset: 0x0000..0x7FFF
                },
                hirom: {
                    bank: 0x30..0x3F,
                    offset: 0x6000..0x7FFF
                },
                exhirom: {
                    bank: 0x80..0xBF,
                    offset: 0x6000..0x7FFF
                }
            }

            ROM = {
                lorom_mirror: {
                    bank: 0x00..0x7D,
                    offset: 0x8000..0xFFFF,
                    page_size: 0x8_000
                },
                lorom: {
                    bank: 0x80..0xFF,
                    offset: 0x8000..0xFFFF,
                    page_size: 0x8_000
                },
                hirom_mirror: {
                    bank: [0x00..0x3F, 0x80..0xBF],
                    offset: 0x8000..0xFFFF,
                    page_size: 0x8_000
                },
                hirom: {
                    bank: 0xC0..0xFF,
                    offset: 0x0000..0xFFFF,
                    page_size: 0x10_000
                }
            }

            class << self
                def check(bank, offset)
                    raise BankOutOfRangeError.new(bank, offset) unless MemoryRange::BANK.include?(bank)
                    raise OffsetOutOfRangeError.new(bank, offset) unless MemoryRange::OFFSET.include?(offset)
                end

                def in_sram_region?(mapping, bank, offset)
                    region = SRAM[mapping]
                    return false unless region

                    region[:bank].include?(bank) && region[:offset].include?(offset)
                end

                def in_bank_ram_low_ram_region?(bank, offset)
                    region = BANK_RAM[:low_ram]
                    region[:bank] == bank && region[:offset].include?(offset)
                end

                def in_lorom_region?(bank, offset)
                    ROM[:lorom][:bank].include?(bank) && ROM[:lorom][:offset].include?(offset)
                end

                def in_lorom_mirror_region?(bank, offset)
                    ROM[:lorom_mirror][:bank].include?(bank) && ROM[:lorom_mirror][:offset].include?(offset)
                end

                def in_hirom_region?(bank, offset)
                    ROM[:hirom][:bank].include?(bank) && ROM[:hirom][:offset].include?(offset)
                end

                def in_hirom_mirror_region?(bank, offset)
                    ROM[:hirom_mirror][:bank].any? { |range| range.include?(bank) } &&
                        ROM[:hirom_mirror][:offset].include?(offset)
                end

                def in_first_hirom_mirror_region?(bank, offset)
                    ROM[:hirom_mirror][:bank].first.include?(bank) && ROM[:hirom][:offset].include?(offset)
                end

                # Method to check if a bank/offset is in the second HiROM mirror region
                def in_second_hirom_mirror_region?(bank, offset)
                    ROM[:hirom_mirror][:bank][1].include?(bank) && ROM[:hirom][:offset].include?(offset)
                end
            end
        end
    end
end
