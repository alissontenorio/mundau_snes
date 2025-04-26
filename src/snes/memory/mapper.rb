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
            def initialize(cartridge, ram, sram, internal_cpu_registers, debug = false)
                @cartridge_type = cartridge.cartridge_type_to_sym
                @rom = cartridge.rom_raw
                @ram = ram
                @sram = sram
                @debug = debug
                @internal_cpu_registers = internal_cpu_registers
            end

            def access(address, operation, value = nil)
                $logger.debug(" ") if @debug

                unless [:read, :write].include?(operation)
                    raise "Invalid operation: #{operation}. Use :read or :write."
                end

                bank = get_bank(address)
                offset = get_offset(address)

                MemoryRange.check(bank, offset)

                case bank_type_for(bank)
                when :system
                    if @debug
                        $logger.debug("Bank System - #{operation.to_s} address 0x#{address.to_s(16).upcase}")
                        # $logger.debug("Cartridge type: #{@cartridge_type}")
                    end
                    access_bank_system(bank, offset, operation, value)
                when :rom
                    if @debug
                        $logger.debug("Bank Rom - #{operation.to_s} address 0x#{address.to_s(16).upcase}")
                        # $logger.debug("Cartridge type: #{@cartridge_type}")
                    end
                    access_bank_rom(bank, offset, operation, value)
                when :ram
                    if @debug
                        $logger.debug("Bank Ram - #{operation.to_s} address 0x#{address.to_s(16).upcase}")
                        # $logger.debug("Cartridge type: #{@cartridge_type}")
                    end
                    access_bank_ram(bank, offset, operation, value)
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

            # Memory Access Banks

            def access_bank_system(bank, offset, operation, value)
                case offset
                when MemoryRange::BANK_SYSTEM_OFFSET[:low_ram]      # 0x0000..0x1FFF
                    access_low_ram(bank, offset, operation, value)
                when MemoryRange::BANK_SYSTEM_OFFSET[:ppu]          # 0x2000..0x21FF
                    access_ppu(bank, offset, operation, value)
                when MemoryRange::BANK_SYSTEM_OFFSET[:apu]          # 0x2000..0x21FF
                    access_apu(bank, offset, operation, value)
                when MemoryRange::BANK_SYSTEM_OFFSET[:controller]   # 0x4000..0x41FF
                    access_controller(bank, offset, operation, value)
                when MemoryRange::BANK_SYSTEM_OFFSET[:internal_cpu] # 0x4200..0x42FF
                    access_internal_cpu(bank, offset, operation, value)
                when MemoryRange::BANK_SYSTEM_OFFSET[:dma]          # 0x4300..0x43FF
                    access_dma(bank, offset, operation, value)
                when MemoryRange::BANK_SYSTEM_OFFSET[:expansion]    # 0x6000..0x7FFF
                    access_sram(bank, offset, operation, value) if MemoryRange.in_sram_region?(@cartridge_type, bank, offset)
                    # ToDo: Deal with the rest
                when MemoryRange::BANK_SYSTEM_OFFSET[:rom]          # 0x8000..0xFFFF
                    access_rom(bank, offset, operation, value)
                else
                    raise AddressOutOfRangeError.new(bank, offset)
                end
            end

            def access_bank_rom(bank, offset, operation, value)
                if MemoryRange.in_sram_region?(@cartridge_type, bank, offset)
                    access_sram(bank, offset, operation, value)
                else
                    access_rom(bank, offset, operation, value) # ToDo: Maybe check if its not in region?
                end
            end

            def access_bank_ram(bank, offset, operation, value)
                if MemoryRange.in_bank_ram_low_ram_region?(bank, offset)
                    access_low_ram(bank, offset, operation, value)
                else
                    access_ram(bank, offset, operation, value)
                end
            end

            # Memory Access Specifics

            def access_sram(bank, offset, operation, value)
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
                if operation == :read
                    @sram[sram_pos]
                elsif operation == :write
                    @sram[sram_pos] = value
                end
            end

            def access_ram(bank, offset, operation, value)
                $logger.debug("#{__method__}\n") if @debug

                ram_pos = position_in_contiguous_memory(bank, offset, 0x7E, 0x0, 0x10_000)

                if operation == :read
                    @ram[ram_pos]
                elsif operation == :write
                    @ram[ram_pos] = value
                end
            end

            def access_low_ram(bank, offset, operation, value)
                $logger.debug("#{__method__}\n") if @debug

                if operation == :read
                    @ram[offset]
                elsif operation == :write
                    @ram[offset] = value
                end
            end

            def access_controller(bank, offset, operation, value)
                $logger.debug("#{__method__}\n") if @debug
            end

            def access_internal_cpu(bank, offset, operation, value)
                $logger.debug("#{__method__} . Register: #{@internal_cpu_registers.address_to_symbol(offset).to_s}\n") if @debug
                if operation == :read
                    @internal_cpu_registers.read(offset)
                elsif operation == :write
                    @internal_cpu_registers.write(offset, value)
                end
            end

            def access_dma(bank, offset, operation, value)
                $logger.debug("#{__method__}\n") if @debug
            end

            def access_rom(bank, offset, operation, value)
                $logger.debug("#{__method__}\n") if @debug
                rom_addr = rom_address(bank, offset)
                # $logger.debug("#{rom_addr.to_s(16)}") if @debug

                @rom[rom_addr].ord if operation == :read
            end

            def access_ppu(bank, offset, operation, value)
                $logger.debug("#{__method__}\n") if @debug
            end

            def access_apu(bank, offset, operation, value)
                $logger.debug("#{__method__}\n") if @debug
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