module Snes
    module CPU
        class InternalCPURegisters
            class Register
                attr_accessor :value
                attr_reader :name, :description

                def initialize(name, description)
                    @name = name
                    @description = description
                    @value = 0
                end
            end

            @registers = {
                # === Writable Registers ===
                0x4200 => Register.new("NMITIMEN", "Interrupt Enable Register (NMI/V-IRQ/H-IRQ)"),
                0x4201 => Register.new("WRIO",     "I/O Port Write Register"),
                0x4202 => Register.new("WRMPYA",   "Multiplicand A"),
                0x4203 => Register.new("WRMPYB",   "Multiplicand B (Start Multiply)"),
                0x4204 => Register.new("WRDIVL",   "Dividend Low Byte"),
                0x4205 => Register.new("WRDIVH",   "Dividend High Byte"),
                0x4206 => Register.new("WRDIVB",   "Divisor (Start Division)"),
                0x4207 => Register.new("HTIMEL",   "H-IRQ Timer Low Byte"),
                0x4208 => Register.new("HTIMEH",   "H-IRQ Timer High Byte"),
                0x4209 => Register.new("VTIMEL",   "V-IRQ Timer Low Byte"),
                0x420A => Register.new("VTIMEH",   "V-IRQ Timer High Byte"),
                0x420B => Register.new("MDMAEN",   "DMA Enable Register"),
                0x420C => Register.new("HDMAEN",   "HDMA Enable Register"),
                0x420D => Register.new("MEMSEL",   "ROM Speed (FastROM Enable)"),

                # === Readable Registers ===
                0x4210 => Register.new("RDNMI",    "NMI Occurred Flag"),
                0x4211 => Register.new("TIMEUP",   "IRQ Occurred Flag"),
                0x4212 => Register.new("HVBJOY",   "PPU Status Register (V/H Blank, Joypad Ready)"),
                0x4213 => Register.new("RDIO",     "I/O Port Read Register"),
                0x4214 => Register.new("RDDIVL",   "Division Result Low Byte"),
                0x4215 => Register.new("RDDIVH",   "Division Result High Byte"),
                0x4216 => Register.new("RDMPYL",   "Multiplication Result Low Byte"),
                0x4217 => Register.new("RDMPYH",   "Multiplication Result High Byte"),
                0x4218 => Register.new("JOY1L",    "Joypad 1 Low Byte"),
                0x4219 => Register.new("JOY1H",    "Joypad 1 High Byte"),
                0x421A => Register.new("JOY2L",    "Joypad 2 Low Byte"),
                0x421B => Register.new("JOY2H",    "Joypad 2 High Byte"),
                0x421C => Register.new("JOY3L",    "Joypad 3 Low Byte"),
                0x421D => Register.new("JOY3H",    "Joypad 3 High Byte"),
                0x421E => Register.new("JOY4L",    "Joypad 4 Low Byte"),
                0x421F => Register.new("JOY4H",    "Joypad 4 High Byte")
            }

            class << self
                def access(operation, address, value = nil)
                    reg = @registers[address]
                    raise CPUInvalidRegisterAddress.new(address) unless reg

                    case operation
                    when :read
                        reg.value
                    when :write
                        reg.value = value & 0xFF
                    else
                        raise "Unknown operation: #{operation}"
                    end
                end

                def info(address)
                    reg = @registers[address]
                    return nil unless reg
                    { name: reg.name, description: reg.description, value: reg.value }
                end

                def debug_print(operation, address, value = nil)
                    info = info(address)
                    write = value ? (" value " + value.to_s(16)) : ''
                    $cpu_logger.debug("InternalCPU Register - #{operation.to_s.capitalize} in address #{address.to_s(16)}#{write} - #{info[:name]} - #{info[:description]}")
                    puts "\e[35mInternalCPU\e[0m register - #{operation.to_s.capitalize}#{write} in address #{address.to_s(16)} - \e[35m#{info[:name]}\e[0m - #{info[:description]}"
                end

                def all
                    @registers
                end
            end
        end
    end
end
