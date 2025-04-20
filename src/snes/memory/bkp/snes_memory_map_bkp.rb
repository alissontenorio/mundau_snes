require_relative '../../../exceptions'
require_relative 'hirom_memory_mapper'
require_relative 'lorom_memory_mapper'


# ToDo: Segmentation Fault
#
# This console also features a special ‘anomaly’ called Open Bus:
# If there is an instruction trying to read from an unmapped/invalid address,
# the last value read is supplied instead (the CPU stores this value in a register
# called Memory Data Register or MDR) and execution carries on in an unpredictable state.
#
# For comparison, the 68000 uses a vector table to handle exceptions, so execution will
# be redirected whenever a fault is detected.

module Snes
    module Memory
        class MemoryMapBKP
            BANK_RANGE = 0x00..0xFF
            OFFSET_RANGE = 0x0000..0xFFFF

            # 960KB is the maximum a SRAM can have, most games use 8KB, I'll just put 32 KB
            SRAM = Array.new(32768, 0) # 32 KB # Max access up to 32767 (0x7FFF)
            RAM = Array.new(131072, 0) # 128 KB # Max access up to 131071 (0x1FFFF)

            def initialize(cartridge)
                @cartridge = cartridge
                @mapper = select_mapper
            end

            def select_mapper
                case @cartridge.cartridge_type
                when "LoROM"
                    LoRomMemoryMapper.new(@cartridge, RAM, SRAM)
                when "HiROM"
                    HiRomMemoryMapper.new(@cartridge, RAM, SRAM)
                when "ExHiROM"
                    # ExHiRomMemoryMapper.new(cartridge)
                    raise NoMethodError.new("Cartridge type not implemented")
                else
                    raise NoMethodError.new("Cartridge type not implemented")
                end
            end

            def range_check(bank, offset)
                unless BANK_RANGE.include?(bank)
                    raise AddressOutOfRangeError.new(
                        "Bank out of range for address #{bank.to_s(16).rjust(2, '0')}:#{offset.to_s(16).rjust(4, '0')}"
                    )
                end

                unless OFFSET_RANGE.include?(offset)
                    raise AddressOutOfRangeError.new(
                        "Offset out of range for address #{bank.to_s(16).rjust(2, '0')}:#{offset.to_s(16).rjust(4, '0')}"
                    )
                end
            end

            def read(address)
                bank = address >> 16
                offset = address & 0x00FFFF

                range_check(bank, offset)

                case bank
                when 0x00..0x3F
                    @mapper.read_first_bank_system(bank, offset)
                when 0x40..0x7D
                    @mapper.read_first_bank_rom(bank, offset)
                when 0x7E, 0x7F
                    @mapper.read_bank_ram(bank, offset)
                when 0x80..0xBF
                    @mapper.read_second_bank_system(bank, offset)
                when 0xC0..0xFF
                    @mapper.read_second_bank_rom(bank, offset)
                else
                    raise "Error unknown reading memory"
                end
            end

                # def read_sram(bank, offset)
                #
                # end
                #
                # def read_ram(bank, offset)
                #
                # end
                #
                # def read_ppu(bank, offset)
                #
                # end
                #
                # def read_joypad(bank, offset)
                #
                # end
                #
                # def read_rom(bank, offset)
                #
                # end

                # def read_first_bank_system(bank, offset)
                #     # if offset.between?(0x0000, 0x1FFF) # WRAM
                #     #     MEDIUM_CLOCK_SPEED
                #     # elsif offset.between?(0x2000, 0x3FFF) # PPU, etc
                #     #     HIGH_CLOCK_SPEED
                #     # elsif offset.between?(0x4000, 0x41FF) # Controller, joystick, joypad
                #     #     LOW_CLOCK_SPEED
                #     # elsif offset.between?(0x4200, 0x5FFF) # CPU, DMA, etc
                #     #     HIGH_CLOCK_SPEED
                #     # elsif offset.between?(0x6000, 0x7FFF) # Expand
                #     #     MEDIUM_CLOCK_SPEED
                #     # elsif offset.between?(0x8000, 0xFFFF)  # ROM
                #     #     MEDIUM_CLOCK_SPEED
                #     # else
                #     #     raise AddressOutOfRangeError("Offset not found for address #{bank}:#{offset}")
                #     # end
                # end

                # def read_second_bank_system(bank, offset)
                #     # if offset.between?(0x0000, 0x1FFF) # WRAM
                #     #     MEDIUM_CLOCK_SPEED
                #     # elsif offset.between?(0x2000, 0x3FFF) # PPU, etc
                #     #     HIGH_CLOCK_SPEED
                #     # elsif offset.between?(0x4000, 0x41FF) # Controller, joystick, joypad
                #     #     LOW_CLOCK_SPEED
                #     # elsif offset.between?(0x4200, 0x5FFF) # CPU, DMA, etc
                #     #     HIGH_CLOCK_SPEED
                #     # elsif offset.between?(0x6000, 0x7FFF) # Expand, SRAM
                #     #     MEDIUM_CLOCK_SPEED
                #     # elsif offset.between?(0x8000, 0xFFFF)  # ROM
                #     #     MEDIUM_CLOCK_SPEED
                #     # else
                #     #     raise AddressOutOfRangeError("Offset not found for address #{bank}:#{offset}")
                #     # end
                # end
                #
                # def read_bank_rom(bank, offset)
                #     # if between 0x40..0x7D
                #     # MEDIUM_CLOCK_SPEED
                #     #
                #     # if between 0xC0..0xFF
                #     # HIGH_CLOCK_SPEED or MEDIUM_CLOCKSPEED
                # end
                #
                # def read_bank_ram(bank, offset)
                #     MEDIUM_CLOCK_SPEED
                # end

                # def get_clock_addr(address)
                #     bank = address >> 16
                #     offset = address & 0x00FFFF
                #     self.get_clock(bank, offset)
                # end
                #
                # def get_clock(bank, offset)
                #     case bank
                #     when 0x00..0x3F
                #         if offset.between?(0x0000, 0x1FFF) # WRAM
                #             MEDIUM_CLOCK_SPEED
                #         elsif offset.between?(0x2000, 0x3FFF) # PPU, etc
                #             HIGH_CLOCK_SPEED
                #         elsif offset.between?(0x4000, 0x41FF) # Controller, joystick, joypad
                #             LOW_CLOCK_SPEED
                #         elsif offset.between?(0x4200, 0x5FFF) # CPU, DMA, etc
                #             HIGH_CLOCK_SPEED
                #         elsif offset.between?(0x6000, 0x7FFF) # Expand
                #             MEDIUM_CLOCK_SPEED
                #         elsif offset.between?(0x8000, 0xFFFF)  # ROM
                #             MEDIUM_CLOCK_SPEED
                #         else
                #             raise AddressOutOfRangeError("Offset not found for address #{bank}:#{offset}")
                #         end
                #     when 0x40..0x7D # ROM
                #         MEDIUM_CLOCK_SPEED
                #     when 0x7E, 0x7F
                #         MEDIUM_CLOCK_SPEED
                #     when 0x80..0xBF
                #         raise "Clock speed not set here"
                #         # if (the value at address $420D (hardware register) is set to 1.)
                #         #     HIGH_CLOCK_SPEED
                #         # else
                #         #     MEDIUM_CLOCK_SPEED
                #         # end
                #     when 0xC0..0xFF
                #         # ToDo: Fix this
                #         raise "Clock speed not set here"
                #         # if (the value at address $420D (hardware register) is set to 1.)
                #         #     HIGH_CLOCK_SPEED
                #         # else
                #         #     MEDIUM_CLOCK_SPEED
                #         # end
                #     else
                #         raise AddressOutOfRangeError.new(
                #             "Bank not found for address #{bank.to_s(16).rjust(2, '0')}:#{offset.to_s(16).rjust(4, '0')}"
                #         )
                #     end
                # end

            # Element        - Address mapped
            # WRAM (8 KByte) - (0000 ~ 1FFF) of banks (00~3F), (80~BF) and 7E
            # WRAM (120 KByte) - (2000 ~ FFFF) of bank 7E and (0000 ~ FFFF) of bank 7F
            #
            # The address (2000 ~ 5FFF) of bank (00~3F), (80~BF) are reserved as a register are of the
            # S-PPU, DMA, etc.D
            #
            #
            # 3 tipos de bancos
            # - Banco de rom (126 bancos desses) (diz que o banco inteiro vai ser pra rom)
            #     40 ~ 7D:xxxx * (Livro diz que de 40 até 7D rodaria a 2.68 Mhz) (Camarada do curso: "SlowRom" -> 2.68 Mhz operation)
            #     C0 ~ FF:xxxx * (Livro diz que de C0 até FF alternaria entre 2.68 e 3.58 Mhz) (Camarada do curso: "FastRom" -> 3.58 MHz operation)
            #
            # - Banco de wram (2 desses bancos), dois bancos reservados para a wram, os bancos 7E e 7F
            #     7E e 7F:xxxx * (Livro diz que rodaria a 2.68 Mhz)
            #
            # - Banco de sistema (128 desses bancos), dois sub-bancos de 8000 até FFFF reservado para rom (32KB) e ai 0000 ate 7FFF reservado para coisas do sistema
            #     * 0000 até 1FFF - Os primeiros 8KBs são mirrors dos 8KBs dos bancos de WRAM (Livro da nintendo concorda e diz que roda a 2.68 Mhz)
            #     * 2100 até 21FF - Diversos registradores para se comunicar com o chip de vídeo / PPU / APU (Livro da nintendo diz que vai de 2000 até 3FFF a 3.58 Mhz)
            #     * 4000 até 40FF - Dois registradores dos controles (old style)  (Livro da nintendo diz que vai do 4000 até 41FF e velocidade de 1.79 Mhz)
            #     * - Registradores da CPU, DMA, HDMA (Tb controles não-old style) (Livro da nintendo diz que vai de 4200 até 5FFF rodando a 3.58 Mhz)
            #     * (Livro da nintendo diz que vai de 6000 até 7FFF e que isso seria a zona de expansão [Chips extras, SRAM] e teria 2.68 Mhz)
            #     00~3F * 8000 até FFFF - (Livro diz que rodaria a 2.68 Mhz) (Camarada do curso: "SlowRom" -> 2.68 Mhz operation)
            #     80~BF * 8000 até FFFF - (Livro diz que rodaria a 2.68 Mhz) (Camarada do curso: "FastRom" -> 3.58 MHz operation)

        end
    end
end

# RAM  = [0] * (2 ** 17 - 1)  # 128 KB
# SRAM = [0] * 0x7FFF         # 32 KB