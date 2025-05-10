module Snes::APU
    class Register
        attr_accessor :value
        attr_reader :name, :description

        def initialize(name, description)
            @name = name
            @description = description
            @value = 0
        end
    end

    class RegisterBank
        attr_accessor :map

        def initialize
            @map = {
                0xF4 => Register.new("APUIO0", "APU IO Registers"),
                0xF5 => Register.new("APUIO1", "APU IO Registers"),
                0xF6 => Register.new("APUIO2", "APU IO Registers"),
                0xF7 => Register.new("APUIO3", "APU IO Registers")
            }
        end

        def [](addr)
            @map[addr]&.value
        end

        def []=(addr, val)
            @map[addr].value = val if @map[addr]
        end
    end
end

#
#     class Registers
#         attr_accessor :registers
#
#         def setup
#             @registers = {
#                 0xF4 => Register.new("APUIO0", "APU IO Registers"), # $2140
#                 0xF5 => Register.new("APUIO1", "APU IO Registers"), # $2141
#                 0xF6 => Register.new("APUIO2", "APU IO Registers"), # $2142
#                 0xF7 => Register.new("APUIO3", "APU IO Registers"), # $2143
#             }
#         end
#
#
#         class << self
#             def access(operation, address, value = nil)
#                 reg = @registers[address]
#                 raise "Invalid register address: 0x#{address.to_s(16)}" unless reg
#
#                 case operation
#                 when :read
#                     reg.value
#                 when :write
#                     reg.value = value & 0xFF
#                 else
#                     raise "Unknown operation: #{operation}"
#                 end
#             end
#
#             def info(address)
#                 reg = @registers[address]
#                 return nil unless reg
#                 { name: reg.name, description: reg.description, value: reg.value }
#             end
#
#             def debug_print(operation, address, value = nil)
#                 cpu_to_apu_io = {
#                     0x2140 => 0xF4,
#                     0x2141 => 0xF5,
#                     0x2142 => 0xF6,
#                     0x2143 => 0xF7
#                 }
#                 info = info(cpu_to_apu_io[address])
#                 write = value ? (" value " + value.to_s(16)) : ''
#                 $apu_logger.debug("APU Register - #{operation.to_s.capitalize} in address #{address.to_s(16)}#{write} - #{info[:name]} - #{info[:description]}\n")
#                 puts "\e[32mAPU\e[0m register - #{operation.to_s.capitalize}#{write} in address #{address.to_s(16)} - \e[32m#{info[:name]}\e[0m - #{info[:description]}"
#             end
#
#             def all
#                 @registers
#             end
#
#             def read_apu_io_registers(addresses)
#                 addresses.to_h { |addr| [addr, access(:read, addr) ] }
#             end
#
#             def write_apu_io_registers(values)
#                 values.each do |address, value|
#                     access(:write, address, value)
#                 end
#             end
#         end
#     end
# end