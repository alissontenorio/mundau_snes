class CartridgeHeaderTypeNotIdentifiedError < StandardError
    def initialize(msg="Couldn't identify the cartridge type (Hirom, Exrom, etc)")
        super
    end
end

class CartridgeNotInsertedError < StandardError
    def initialize(msg="Cartridge not inserted")
        super
    end
end