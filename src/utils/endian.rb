module Utils
    module Endian
        include BaseConverter

        def little_endian_bin(hex1, hex2)
            hex_leading_zeroes(hex2) + hex_leading_zeroes(hex1)
        end
    end
end

