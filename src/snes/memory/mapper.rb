require_relative '../../exceptions'
require 'logger'
require_relative 'memory_range'

# ToDo: Segmentation Fault
#
# This console also features a special ‘anomaly’ called Open Bus:
# ToDo: If there is an instruction trying to read from an unmapped/invalid address,
# the last value read is supplied instead (the CPU stores this value in a register
# called Memory Data Register or MDR) and execution carries on in an unpredictable state.
#
# For comparison, the 68000 uses a vector table to handle exceptions, so execution will
# be redirected whenever a fault is detected.

module Snes
    module Memory
        class Mapper
            def initialize(cartridge, ram, sram, debug = false)
                @cartridge_type = cartridge.cartridge_type_to_sym
                @rom = cartridge.rom_raw
                @ram = ram
                @sram = sram
                @debug = debug
            end

            def read(address)
                if @debug
                    $logger.debug("Read address 0x#{address.to_s(16).upcase}")
                    # $logger.debug("Cartridge type: #{@cartridge_type}")
                end

                bank = get_bank(address)
                offset = get_offset(address)

                MemoryRange.check(bank, offset)

                case bank_type_for(bank)
                when :system
                    read_bank_system(bank, offset)
                when :rom
                    read_bank_rom(bank, offset)
                when :ram
                    read_bank_ram(bank, offset)
                else
                    raise BankOutOfRangeError, "Unknown bank #{bank.to_s(16)}"
                end
            end

            protected

            def get_bank(address)
                address >> 16
            end

            def get_offset(address)
                address & 0x00FFFF
            end

            def position_in_contiguous_memory(bank, offset, first_bank, first_offset, page_size)
                offset - first_offset + ((bank - first_bank) * page_size)
            end

            def bank_type_for(bank)
                MemoryRange::BANKS.each do |type, ranges|
                    return type if ranges.any? { |r| r.include?(bank) }
                end
                nil
            end

            # Read Banks

            def read_bank_system(bank, offset)
                $logger.debug("Bank System") if @debug

                case offset
                when MemoryRange::BANK_SYSTEM_OFFSET[:low_ram]
                    read_low_ram(bank, offset)
                when MemoryRange::BANK_SYSTEM_OFFSET[:ppu]
                    read_ppu(bank, offset)
                when MemoryRange::BANK_SYSTEM_OFFSET[:controller]
                    read_controller(bank, offset)
                when MemoryRange::BANK_SYSTEM_OFFSET[:cpu_dma]
                    read_cpu_dma(bank, offset)
                when MemoryRange::BANK_SYSTEM_OFFSET[:expansion]
                    read_sram(bank, offset) if MemoryRange.in_sram_region?(@cartridge_type, bank, offset)
                    # ToDo: Deal with the rest
                when MemoryRange::BANK_SYSTEM_OFFSET[:rom]
                    read_rom(bank, offset)
                else
                    raise AddressOutOfRangeError.new(bank, offset)
                end
            end

            def read_bank_rom(bank, offset)
                $logger.debug("Bank Rom") if @debug

                if MemoryRange.in_sram_region?(@cartridge_type, bank, offset)
                    read_sram(bank, offset)
                else
                    read_rom(bank, offset) # ToDo: Maybe check if its not in region?
                end
            end

            def read_bank_ram(bank, offset)
                $logger.debug("Bank Ram") if @debug

                if MemoryRange.in_bank_ram_low_ram_region?(bank, offset)
                    read_low_ram(bank, offset)
                else
                    read_ram(bank, offset)
                end
            end

            # Read Specifics

            def read_sram(bank, offset)
                $logger.debug("#{__method__}") if @debug

                case @cartridge_type
                when :hirom
                    first_bank = MemoryRange::SRAM[:hirom][:bank].begin
                    first_offset = MemoryRange::SRAM[:hirom][:offset].begin
                    page_size = MemoryRange::SRAM[:hirom][:offset].size
                when :lorom
                    first_bank = MemoryRange::SRAM[:lorom][:bank].begin
                    first_offset = MemoryRange::SRAM[:lorom][:offset].begin
                    page_size = MemoryRange::SRAM[:lorom][:offset].size
                when :exhirom
                    first_bank = MemoryRange::SRAM[:exhirom][:bank].begin
                    first_offset = MemoryRange::SRAM[:exhirom][:offset].begin
                    page_size = MemoryRange::SRAM[:exhirom][:offset].size
                end

                sram_pos = position_in_contiguous_memory(bank, offset, first_bank, first_offset, page_size)
                @sram[sram_pos]
            end

            def read_ram(bank, offset)
                $logger.debug("#{__method__}") if @debug
                ram_pos = position_in_contiguous_memory(bank, offset, 0x7E, 0x0, 0x10_000)
                @ram[ram_pos]
            end

            def read_low_ram(bank, offset)
                $logger.debug("#{__method__}") if @debug
                @ram[offset]
            end

            def read_controller(bank, offset)
                $logger.debug("#{__method__}") if @debug
            end

            def read_cpu_dma(bank, offset)
                $logger.debug("#{__method__}") if @debug
            end

            def read_rom(bank, offset)
                # $logger.debug("#{__method__}") if @debug
                rom_addr = rom_address(bank, offset)
                $logger.debug("#{rom_addr.to_s(16)}") if @debug
                @rom[rom_addr]
            end

            def read_ppu(bank, offset)
                $logger.debug("#{__method__}") if @debug
            end

            # Convert the Snes address to the ROM address
            # ToDo: Rename method to something more appropriate
            def rom_address(bank, offset)
                bank_pos = bank
                case @cartridge_type
                when :hirom
                    if MemoryRange.in_hirom_region?(bank, offset)
                        full_address = (bank << 16) + offset
                        full_address - 0xC00000
                    elsif MemoryRange.in_first_hirom_mirror_region?(bank, offset)
                        # Hirom mirror region are separated.
                        # There is a gap between the first and second mirror region.
                        page_size = MemoryRange::ROM[:hirom_mirror][:page_size]
                        ((bank  & 0x7F) * page_size) + (offset & 0x7FFF)
                    elsif MemoryRange.in_second_hirom_mirror_region?(bank, offset)
                        page_size = MemoryRange::ROM[:hirom_mirror][:page_size]
                        (((bank - 0x40) & 0x7F) * page_size) + (offset & 0x7FFF)
                    end
                when :lorom
                    page_size = MemoryRange::ROM[:lorom][:page_size]
                    ((bank  & 0x7F) * page_size) + (offset & 0x7FFF)
                when :exhirom
                    raise NotImplementedError, "#{__method__} is not yet implemented for exhirom"
                end
            end

            # read dma/ppu2/hardware_registers
            # read special chips
            # write
        end
    end
end