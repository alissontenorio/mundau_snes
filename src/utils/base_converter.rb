module Utils
    class BaseConverter
        class << self
            # "0A".to_i(16) #=>10
            def hex_to_integer(hex)
                hex.to_i(16)
            end

            # integer to hex
            # 10.to_s(16) #=> "a"
            # 128.chr -> "\x80"
            def integer_to_ascii(integer)
                integer.chr
            end

            def integer_to_binary(integer)
                integer.to_s(2)
            end

            def integer_to_hex(integer)
                integer.to_s(16)
            end

            def binary_to_integer(binary)
                binary.to_i(2)
            end

            def binary_to_hex(binary)
                binary.to_i(2).to_s(16)
            end

            def hex_leading_zeroes(hex, leading_number=2)
                # leading number 2, if you receive 'A' will return '0A'
                # if number is 4 and receive '1B' will return '001B'
                hex.rjust(leading_number, '0')
            end

            def binary_leading_zeroes_byte(byte)
                byte.rjust(8, '0')
            end

            def digits_from_byte_from_hex_number(hex)
                second_part, first_part = hex.digits(16)
                second_part = 0 if second_part.nil?
                first_part = 0 if first_part.nil?
                [first_part, second_part]
            end

            # "\x80".force_encoding(Encoding::ASCII_8BIT).ord -> 128
            def hex_force_ascii_encoding(hex)
                hex.force_encoding(Encoding::ASCII_8BIT)
            end

            def hex_force_ascii_encoding_ord(hex)
                hex.force_encoding(Encoding::ASCII_8BIT).ord
            end

            # 0x8f.chr -> "\x8F"
            def hex_other_representation(hex)
                hex.chr
            end
        end
    end
end
