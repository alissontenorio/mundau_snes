module MundauSnesTest
    class DataMovementTest < CPUTest

        def test_sta_abs_8_bits
            # opcode: 8D operands: 00 21
            @@core.pc = 0x8018
            @@core.a = 0x80

            @@core.fetch_decode_execute

            assert_equal 'Store Accumulator To Memory', @@core.current_opcode_data.description
            assert_equal 4, @@core.cycles
            assert_equal 0x801b, @@core.pc
            assert_equal 0x2100, @ppu_register[:address][0]
            assert_equal 0x80, @ppu_register[:value][0]
        end

        def test_sta_abs_16_bits
            # opcode: 8D operands: 00 21
            @@core.pc = 0x8018
            @@core.a = 0x8067
            @@core.set_p_flag(:m, false)

            @@core.fetch_decode_execute

            assert_equal 'Store Accumulator To Memory', @@core.current_opcode_data.description
            assert_equal 5, @@core.cycles
            assert_equal 0x801b, @@core.pc
            assert_equal 0x2100, @ppu_register[:address][0]
            assert_equal 0x2101, @ppu_register[:address][1]
            assert_equal 0x67, @ppu_register[:value][0]
            assert_equal 0x80, @ppu_register[:value][1]
        end

        # def test_sta_abs_8_bits
        #     opcode_data = @opcodes_table[0x8D]
        #     base_cycles = opcode_data.cycles
        #     @@core.pc &= 0xFFFF   # If PC exceeeds FFFF
        #     pc_expected = @@core.increment_pc(opcode_data.bytes_used)
        #     pc_expected = @@core.full_pc(pc_expected[0], pc_expected[1])
        #     @@core.increment_pc!
        #     @@core.cycles += base_cycles
        #     @@core.define_singleton_method(:read_16) do
        #         0x2100  # return mock value, 2100 - goes to ppu
        #     end
        #
        #     @@core.a = 0x80
        #
        #     cpu_test_instance =  self
        #
        #     @@console.bus.define_singleton_method(:write_ppu) do |address, value|
        #         cpu_test_instance.instance_variable_get(:@writes_8['value']) << value
        #     end
        #
        #     @@core.sta_abs
        #
        #     assert_equal 'Store Accumulator To Memory', opcode_data.description
        #     assert_equal 4, @@core.cycles
        #     assert_equal pc_expected, @@core.pc
        #     assert_equal 0x80, @writes_8[0]
        # end
        #
        # def test_sta_abs_16_bits
        #     opcode_data = @opcodes_table[0x8D]
        #     base_cycles = opcode_data.cycles
        #     @@core.pc &= 0xFFFF   # If PC exceeeds FFFF
        #     pc_expected = @@core.increment_pc(opcode_data.bytes_used)
        #     pc_expected = @@core.full_pc(pc_expected[0], pc_expected[1])
        #     @@core.increment_pc!
        #     @@core.cycles += base_cycles
        #     @@core.define_singleton_method(:read_16) do
        #         0x2100  # return mock value
        #     end
        #
        #     @@core.a = 0x8067 # store 80 to accumulator
        #
        #     cpu_test_instance =  self
        #
        #     @@console.bus.define_singleton_method(:write_ppu) do |address, value|
        #         cpu_test_instance.instance_variable_get(:@writes_16['value']) << value
        #     end
        #
        #     @@core.p = 0b00010100 # make m = 0
        #     @@core.sta_abs
        #
        #     assert_equal 'Store Accumulator To Memory', opcode_data.description
        #     assert_equal 5, @@core.cycles
        #     assert_equal pc_expected, @@core.pc
        #     assert_equal 0x67, @writes_16[0]
        #     assert_equal 0x80, @writes_16[1]
        # end
    end
end