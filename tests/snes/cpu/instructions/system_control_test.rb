module MundauSnesTest
    class SystemControlTest < CPUTest
        def test_sei
            opcode_data = @opcodes_table[0x78] # sei
            base_cycles = opcode_data.cycles
            pc_expected  = @@core.pc + opcode_data.bytes_used
            @@core.pc &= 0xFFFF   # If PC exceeeds FFFF
            @@core.increment_pc!

            @@core.cycles += base_cycles
            @@core.sei # Call Instruction
            i = (@@core.p>>2) & 1

            assert_equal 'Set Interrupt Disable Flag', opcode_data.description
            assert_equal 2, @@core.cycles
            assert_equal pc_expected, @@core.pc
            assert_equal 1, i

        end
    end
end