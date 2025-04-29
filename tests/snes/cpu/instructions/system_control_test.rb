module MundauSnesTest
    class CPUSystemControlTest < CPUTest
        def test_sei
            # opcode: 0x78 operands unary
            @@core.pc = 0x8000
            @@core.set_p_flag(:i, false)

            @@core.fetch_decode_execute

            assert_equal 'Set Interrupt Disable Flag', @@core.current_opcode_data.description
            assert_equal 2, @@core.cycles
            assert_equal true, @@core.status_p_flag?(:i)
        end
    end
end