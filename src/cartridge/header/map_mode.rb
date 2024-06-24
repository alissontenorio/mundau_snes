require_relative '../../utils/base_converter'

# ||____________________MapMode:
# |                     $XO = LoROM/32K Banks            (Mode 20)
# |                     $X1 = HiROM/64K Banks            (Mode 21)
# |                     $X2 = LoROM/32K Banks + S-DD1    (Mode 22 Mappable)
# Speed                 $X3 = LoROM/32K Banks + SA-1     (Mode 23 Mappable)
# $2X = SlowROM (200ns) $X5 = HiROM/64K Banks            (Mode 25 ExHiROM)
# $3X = FastROM (120ns) $XA = HiROM/64K Banks + SPC7110  (Mode 2A Mappable)
module Rom
    class MapMode
        include Utils::BaseConverter

        # makeup_raw:
        # 001smmmm
        # |++++- Map mode
        # +----- Speed: 0=Slow, 1=Fast
        ROM_TYPES = {
            0 => ["LoROM", "Mode 20"],
            1 => ["HiROM", "Mode 21"],
            2 => ["LoROM", "Mode 22", "Mappable"],
            3 => ["LoROM", "Mode 23", "Mappable"],
            5 => ["ExHiROM", "Mode 25", "ExHiROM"],
            10 => ["HiRom", "Mode 2A", "Mappable"]
        }

        SPEED = {
            0 => "Slow", # 2.68 Mhz operation
            1 => "Fast"  # 3.58 MHz operation
        }

        MODES = {

        }

        attr_accessor :map_mode_raw, :speed, :map_mode

        def initialize(map_mode_raw)
            map_mode_bin = binary_leading_zeroes_byte(integer_to_binary(map_mode_raw))
            map_mode_fix_begin, speed_raw, map_mode_raw = map_mode_bin[0..2], map_mode_bin[3],  map_mode_bin[4..7]
            # ToDo: improve exception
            raise "Map mode byte doesn't start with 001" if map_mode_fix_begin != "001"

            @map_mode = ROM_TYPES[binary_to_integer(map_mode_raw)]
            @speed = SPEED[binary_to_integer(speed_raw)]
        end
    end
end