# $00 = (J)apan               (NTSC), $09 = (D)Germany, Austria, Sw...
# $01 = (E)USA, Canada        (NTSC), $0A = (I)taly
# $02 = Euro(P)e               (PAL), $0B = (C)hina, Hong Kong
# $03 = S(W)eden, Scandinavia  (PAL), $0C = Indonesia
# $04 = Finland                (PAL), $0D = South (K)orea
# $05 = Denmark                (PAL), $0E = (A)Common
# $06 = (F)rance             (SECAM), $0F = Ca(N)ada
# $07 = (H)olland              (PAL), $10 = (B)razil
# $08 = (S)pain                $(PAL), $11 = (U)Australia
module Rom
    class Country
        MAP = {
            0 => "(J)apan",
            1 => "(E)USA, Canada",
            2 => "Euro(P)e",
            3 => "S(W)eden, Scandinavia",
            4 => "Finland",
            5 => "Denmark",
            6 => "(F)rance",
            7 => "(H)olland",
            8 => "(S)pain",
            9 => "(D)Germany, Austria, Sw...",
            10 => "(I)taly",
            11 => "(C)hina, Hong Kong",
            12 => "Indonesia",
            13 => "South (K)orea",
            14 => "(A)Common",
            15 => "Ca(N)ada",
            16 => "(B)razil",
            17 => "(U)Australia",
            18 => "(X)Other Variation",
            19 => "(Y)Other Variation",
            20 => "(Z)Other Variation",
        }

        attr_accessor :country_code

        def initialize(code)
            @country_code = MAP[code]
        end
    end
end