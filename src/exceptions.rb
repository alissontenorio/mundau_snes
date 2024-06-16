class RomHeaderTypeNotIdentifiedError < StandardError
    def initialize(msg="Couldn't identify the cartridge type (Hirom, Exrom, etc)")
        super
    end
end
