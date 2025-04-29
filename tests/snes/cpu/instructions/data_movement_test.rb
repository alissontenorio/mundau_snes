module MundauSnesTest
    class DataMovementTest < CPUTest
        def test_sta_abs_8_bits
            opcode_data = @opcodes_table[0x8D]
            base_cycles = opcode_data.cycles
            @@core.pc &= 0xFFFF   # If PC exceeeds FFFF
            pc_expected = @@core.increment_pc(opcode_data.bytes_used)
            pc_expected = @@core.full_pc(pc_expected[0], pc_expected[1])
            @@core.increment_pc!
            @@core.cycles += base_cycles
            @@core.define_singleton_method(:read_16) do
                0x2100  # return mock value
            end

            @@core.a = 0x80

            @@console.bus.define_singleton_method(:write_ppu) do |address, value|
                nil
            end

            @@core.sta_abs

            assert_equal 'Store Accumulator To Memory', opcode_data.description
            assert_equal 4, @@core.cycles
            assert_equal pc_expected, @@core.pc
            assert_equal 0x80, @@core.a
        end

        def test_sta_abs_16_bits
            opcode_data = @opcodes_table[0x8D]
            base_cycles = opcode_data.cycles
            @@core.pc &= 0xFFFF   # If PC exceeeds FFFF
            pc_expected = @@core.increment_pc(opcode_data.bytes_used)
            pc_expected = @@core.full_pc(pc_expected[0], pc_expected[1])
            @@core.increment_pc!
            @@core.cycles += base_cycles
            @@core.define_singleton_method(:read_16) do
                0x2100  # return mock value
            end

            @@core.a = 0x80

            @@console.bus.define_singleton_method(:write_ppu) do |address, value|
                nil
            end

            @@core.p = 0b00010100
            @@core.sta_abs

            assert_equal 'Store Accumulator To Memory', opcode_data.description
            assert_equal 5, @@core.cycles
            assert_equal pc_expected, @@core.pc
            assert_equal 0x80, @@core.a
        end
    end
end