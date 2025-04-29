require_relative '../../../src/utils/file'

module MundauSnesTest
    class CPUTest < Minitest::Test
        include Utils::FileOperations

        attr_accessor :console, :cartridge, :core, :internal_cpu_registers

        @@setup_once_done = false
        @@console = nil
        @@core = nil
        @@cartridge
        @@internal_cpu_registers

        def setup
            unless @@setup_once_done
                setup_once
                @@setup_once_done = true
            end
            @@core.setup(@@console.m_map, @@cartridge.emulation_vectors[:reset], @@internal_cpu_registers)
            @opcodes_table = @@core.opcodes_table
            @writes_8 = []
            @writes_16 = []
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
        end

        # def teardown
        #     @core.setup(nil, nil, nil)
        #     @console.remove_cartridge
        # end
    end
end