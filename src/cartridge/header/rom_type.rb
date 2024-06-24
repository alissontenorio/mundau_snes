require_relative '../../utils/base_converter'

#  ROM TYPE (Bits 7-4 = Co-processor, Bits 3-0 = Type)
#  ||____________________Type:
#  |                     $00 = ROM
#  |                     $01 = ROM+RAM
# Co-processor:          $02 = ROM+RAM+Battery
# $0X = DSP              $X3 = ROM+Co-processor
# $1X = GSU (SuperFX)    $X4 = ROM+Co-processor+RAM
# $2X = OBC1             $X5 = ROM+Co-processor+RAM+Battery
# $3X = SA-1             $X6 = ROM+Co-processor+Battery
# $4X = S-DD1            $X9 = ROM+Co-processor+RAM+Battery+RTC-4513...
# $5X = S-RTC            $XA = ROM+Co-processor+RAM+Battery+Overclock...
# $Ex - Coprocessor is Other (Super Game Boy/Satellaview)
# $Fx - Coprocessor is Custom (specified with $FFBF)
module Rom
    class Type
        include Utils::BaseConverter

        CO_PROCESSORS = {
            0 => "DSP",
            1 => "GSU",
            2 => "OBC1",
            3 => "SA-1",
            4 => "S-DD1",
            5 => "S-RTC",
            14 => "Other", # E
            15 => "Custom" # F
        }

        TYPE = {
            0 => "ROM",
            1 => "ROM + RAM",
            2 => "ROM + RAM + Battery",
            3 => "ROM + Co-processor",
            4 => "ROM + Co-processor + RAM",
            5 => "ROM + Co-processor + RAM + Battery",
            6 => "ROM + Co-processor + Battery",
            9 => "ROM + Co-processor + RAM+Battery + RTC-4513...",
            10 => "ROM + Co-processor + RAM + Battery + Overclock...", # A
        }

        attr_accessor :has_co_processor, :rom_type, :co_processor

        def initialize(rom_type)
            first_part, second_part = digits_from_byte_from_hex_number(rom_type.ord)
            @has_co_processor = rom_type.ord >= 3
            @rom_type = TYPE[second_part]
            # ToDo: select when co_processor is custom from $FFBF  https://snes.nesdev.org/wiki/ROM_header
            @co_processor = @has_co_processor ? CO_PROCESSORS[first_part] : nil
        end
    end
end