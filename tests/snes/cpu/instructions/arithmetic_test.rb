module MundauSnesTest
    class CPUArithmeticTest < CPUTest
        # def test_inx_zero_8_bits
        #     # opcode: 0xE8 operands unary
        #     @@core.pc = 0x8729
        #     @@core.x = -1
        #     @@core.set_p_flag(:x, true)
        #
        #     @@core.fetch_decode_execute
        #
        #     assert_equal 'Increment X register', @@core.current_opcode_data.description
        #     assert_equal 2, @@core.cycles
        #     assert_equal false, @@core.status_p_flag?(:n)
        #     assert_equal true, @@core.status_p_flag?(:z)
        #     assert_equal 0, @@core.x
        # end
        #
        # def test_inx_8_bits
        #     # opcode: 0xE8 operands unary
        #     @@core.pc = 0x8729
        #     @@core.x = 2
        #     @@core.set_p_flag(:x, true)
        #
        #     @@core.fetch_decode_execute
        #
        #     assert_equal 'Increment X register', @@core.current_opcode_data.description
        #     assert_equal 2, @@core.cycles
        #     assert_equal false, @@core.status_p_flag?(:n)
        #     assert_equal false, @@core.status_p_flag?(:z)
        #     assert_equal 3, @@core.x
        # end
        #
        # def test_inx_16_bits
        #     # opcode: 0xE8 operands unary
        #     @@core.pc = 0x8729
        #     @@core.x = 300
        #     @@core.set_p_flag(:x, false)
        #
        #     @@core.fetch_decode_execute
        #
        #     assert_equal 'Increment X register', @@core.current_opcode_data.description
        #     assert_equal 2, @@core.cycles
        #     assert_equal false, @@core.status_p_flag?(:n)
        #     assert_equal false, @@core.status_p_flag?(:z)
        #     assert_equal 301, @@core.x
        # end
        #
        # def test_inx_negative_8_bits
        #     # opcode: 0xE8 operands unary
        #     @@core.pc = 0x8729
        #     @@core.x = -2
        #     @@core.set_p_flag(:x, true)
        #
        #     @@core.fetch_decode_execute
        #
        #     assert_equal 'Increment X register', @@core.current_opcode_data.description
        #     assert_equal 2, @@core.cycles
        #     assert_equal true, @@core.status_p_flag?(:n)
        #     assert_equal false, @@core.status_p_flag?(:z)
        #     assert_equal 0b1111_1111, @@core.x # -1
        # end
        #
        # def test_inx_negative_16_bits
        #     # opcode: 0xE8 operands unary
        #     @@core.pc = 0x8729
        #     @@core.x = -300
        #     @@core.set_p_flag(:x, false)
        #
        #     @@core.fetch_decode_execute
        #
        #     assert_equal 'Increment X register', @@core.current_opcode_data.description
        #     assert_equal 2, @@core.cycles
        #     assert_equal true, @@core.status_p_flag?(:n)
        #     assert_equal false, @@core.status_p_flag?(:z)
        #     assert_equal 0b1111_1110_1101_0101, @@core.x # -299
        # end
    end
end