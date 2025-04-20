require_relative '../../exceptions'

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
                ppu:          0x2000..0x3FFF,
                controller:   0x4000..0x41FF,
                cpu_dma:      0x4200..0x5FFF,
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

            def self.check(bank, offset)
                raise BankOutOfRangeError.new(bank, offset) unless MemoryRange::BANK.include?(bank)
                raise OffsetOutOfRangeError.new(bank, offset) unless MemoryRange::OFFSET.include?(offset)
            end

            def self.in_sram_region?(mapping, bank, offset)
                region = SRAM[mapping]
                return false unless region

                region[:bank].include?(bank) && region[:offset].include?(offset)
            end

            def self.in_bank_ram_low_ram_region?(bank, offset)
                region = BANK_RAM[:low_ram]
                region[:bank] == bank && region[:offset].include?(offset)
            end
        end
    end
end
