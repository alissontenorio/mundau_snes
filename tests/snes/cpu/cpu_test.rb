require_relative '../../../src/utils/file'

module MundauSnesTest
    class CPUTest < Minitest::Test
        include Utils::FileOperations

        attr_accessor :console, :cartridge, :core, :internal_cpu_registers

        @@setup_once_done = false
        @@console = nil
        @@core = nil
        @@ppu = nil
        @@cartridge
        @@internal_cpu_registers

        def write_ppu_register
            @write_ppu_register
        end

        def setup
            unless @@setup_once_done
                setup_once
                @@setup_once_done = true
            end
            @@core.setup(@@console.m_map, @@cartridge.emulation_vectors[:reset], @@internal_cpu_registers)
            @opcodes_table = @@core.opcodes_table
            @ppu_register = { address: [], value: [] }
            # @writes_16 = { address: 0, value: [] }
            # @writes_24 = { address: 0, value: [] }

            @frame_buffer = @@ppu.get_frame_buffer

            @original_write_register = @@ppu.method(:write_register)
            cpu_test_instance =  self
            @@ppu.define_singleton_method(:write_register) do |address, value|
                @ppu_register = cpu_test_instance.instance_variable_get(:@ppu_register)
                @ppu_register[:address] << address
                @ppu_register[:value] << value
            end

            # cpu_test_instance = self
            # @@core.define_singleton_method(:write_8) do |address, value|
            #     cpu_test_instance.instance_variable_get(:@writes_8) << [address, value]
            # end
            #
            # @@core.define_singleton_method(:write_16) do |address, value|
            #     @writes_16 << [address, value]
            # end
        end

        def setup_once
            rom_filepath = File.expand_path('../../assets/test_rom.smc', __dir__)
            rom_raw = open_rom(rom_filepath)
            @@console = Snes::Console.instance
            @@console.setup
            @@console.insert_cartridge(rom_raw)
            @@cartridge = @@console.cartridge
            @@core = Snes::CPU::WDC65816.new
            @@internal_cpu_registers = Snes::CPU::InternalCPURegisters.new
            @@console.m_map.set_internal_cpu_registers(@@internal_cpu_registers)
            @@ppu = Snes::PPU::PPU.new
            @@ppu.setup
            @@console.bus.ppu = @@ppu
        end

        def teardown
            @@ppu.define_singleton_method(:write_register, &@original_write_register)
            # @core.setup(nil, nil, nil)
            # @console.remove_cartridge
        end
    end
end