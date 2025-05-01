module MundauSnesTest
    class CPUDataMovementTest < CPUTest
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

        def test_stz_abs_8_bits
            # opcode: 0x9C operands 00 42
            @@core.pc = 0x8001
            @@core.dbr = 0

            @@core.fetch_decode_execute

            assert_equal 'Store Zero to Memory', @@core.current_opcode_data.description
            assert_equal 4, @@core.cycles
            assert_equal 0x8004, @@core.pc
            assert_equal 0x4200, @internal_cpu_register[:address][0]
            assert_equal 0, @internal_cpu_register[:value][0]
        end

        def test_stz_abs_16_bits
            # opcode: 0x9C operands 00 42
            @@core.pc = 0x8001
            @@core.dbr = 0
            @@core.set_p_flag(:m, false)

            @@core.fetch_decode_execute

            assert_equal 'Store Zero to Memory', @@core.current_opcode_data.description
            assert_equal 5, @@core.cycles
            assert_equal 0x8004, @@core.pc
            assert_equal 0x4200, @internal_cpu_register[:address][0]
            assert_equal 0x4201, @internal_cpu_register[:address][1]
            assert_equal 0, @internal_cpu_register[:value][0]
            assert_equal 0, @internal_cpu_register[:value][1]
        end

        def test_lda_immediate_8_bit
            # Opcode 0xA9 Operand 01
            @@core.pc = 0x8388

            @@core.fetch_decode_execute

            assert_equal 'Load Accumulator from Memory', @@core.current_opcode_data.description
            assert_equal 2, @@core.cycles
            assert_equal 0x838A, @@core.pc
            assert_equal 0x01, @@core.a
            assert_equal false, @@core.status_p_flag?(:z)
            assert_equal false, @@core.status_p_flag?(:n)
        end

        def test_lda_immediate_16_bit
            # Opcode 0xA9 Operand 00 60
            @@core.pc = 0x8398

            @@core.set_p_flag(:m, false)
            @@core.fetch_decode_execute

            assert_equal 'Load Accumulator from Memory', @@core.current_opcode_data.description
            assert_equal 3, @@core.cycles
            assert_equal 0x839B, @@core.pc
            assert_equal 0x6000, @@core.a
            assert_equal false, @@core.status_p_flag?(:z)
            assert_equal false, @@core.status_p_flag?(:n)
        end

        def test_lda_immediate_zero_8_bit
            # Opcode 0xA9 Operand 80
            @@core.pc = 0x801F

            @@core.fetch_decode_execute

            assert_equal 'Load Accumulator from Memory', @@core.current_opcode_data.description
            assert_equal 2, @@core.cycles
            assert_equal 0x8021, @@core.pc
            assert_equal 0, @@core.a
            assert_equal true, @@core.status_p_flag?(:z)
            assert_equal false, @@core.status_p_flag?(:n)
        end

        def test_lda_immediate_negative_8_bit
            # Opcode 0xA9 Operand 80
            @@core.pc = 0x8016

            @@core.fetch_decode_execute

            assert_equal 'Load Accumulator from Memory', @@core.current_opcode_data.description
            assert_equal 2, @@core.cycles
            assert_equal 0x8018, @@core.pc
            assert_equal 0x80, @@core.a
            assert_equal false, @@core.status_p_flag?(:z)
            assert_equal true, @@core.status_p_flag?(:n)
        end

        def test_lda_immediate_negative_16_bit
            # Opcode 0xA9 Operand 80 8D
            @@core.pc = 0x8016

            @@core.set_p_flag(:m, false)
            @@core.fetch_decode_execute

            assert_equal 'Load Accumulator from Memory', @@core.current_opcode_data.description
            assert_equal 3, @@core.cycles
            assert_equal 0x8019, @@core.pc
            assert_equal 0x8D80, @@core.a
            assert_equal false, @@core.status_p_flag?(:z)
            assert_equal true, @@core.status_p_flag?(:n)
        end

        def test_xce_entering_emulation_mode
            # Opcode 0xFB
            @@core.pc = 0x801C
            @@core.emulation_mode = false
            @@core.sp = 0x2384
            @@core.x = 0x3345
            @@core.y = 0x5678
            @@core.set_p_flag(:c, true)
            @@core.set_p_flag(:m, false)
            @@core.set_p_flag(:x, false)

            @@core.fetch_decode_execute

            assert_equal 'Exchange Carry and Emulation Bits', @@core.current_opcode_data.description
            assert_equal 2, @@core.cycles
            assert_equal 0x801D, @@core.pc
            assert_equal 0x0184, @@core.sp
            assert_equal 0x45, @@core.x
            assert_equal 0x78, @@core.y
            assert_equal true, @@core.emulation_mode
            assert_equal false, @@core.status_p_flag?(:c)
            assert_equal true, @@core.status_p_flag?(:m)
            assert_equal true, @@core.status_p_flag?(:x)
        end

        def test_xce_exiting_emulation_mode
            # Opcode 0xFB
            @@core.pc = 0x801C
            @@core.emulation_mode = true
            @@core.sp = 0x184
            @@core.x = 0x45
            @@core.y = 0x78
            @@core.set_p_flag(:c, false)

            @@core.fetch_decode_execute

            assert_equal 'Exchange Carry and Emulation Bits', @@core.current_opcode_data.description
            assert_equal 2, @@core.cycles
            assert_equal 0x801D, @@core.pc
            assert_equal 0x0184, @@core.sp
            assert_equal 0x45, @@core.x
            assert_equal 0x78, @@core.y
            assert_equal false, @@core.emulation_mode
            assert_equal true, @@core.status_p_flag?(:c)
        end
    end
end