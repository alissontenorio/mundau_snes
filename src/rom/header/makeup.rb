require_relative '../../utils/base_converter'

module Rom
    class Makeup
        # makeup_raw:
        # 001smmmm
        # |++++- Map mode
        # +----- Speed: 0=Slow, 1=Fast

        ROM_TYPES = {
            0 => "LoROM",
            1 => "HiROM",
            5 => "ExHiROM"
        }

        SPEED = {
            0 => "Slow",
            1 => "Fast"  # 3.58MHz operation
        }

        MODES = {

        }

        attr_accessor :makeup_raw, :speed, :map_mode

        def initialize(makeup_raw)
            makeup_bin = Utils::BaseConverter::binary_leading_zeroes_byte(Utils::BaseConverter::integer_to_binary(makeup_raw))
            makeup_fix_begin, speed_raw, map_mode_raw = makeup_bin[0..2], makeup_bin[3],  makeup_bin[4..7]
            # ToDo: improve exception
            raise Exception("Makeup byte doesn't start with 001") if makeup_fix_begin != "001"

            @map_mode = ROM_TYPES[Utils::BaseConverter::binary_to_integer(map_mode_raw)]
            @speed = SPEED[Utils::BaseConverter::binary_to_integer(speed_raw)]
        end
    end
end