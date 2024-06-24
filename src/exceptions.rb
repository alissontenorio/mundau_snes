class CartridgeHeaderTypeNotIdentifiedError < StandardError
    def initialize(msg="Couldn't identify the cartridge type (Hirom, Exrom, etc)")
        super
    end
end

class AddressOutOfRangeError < StandardError
    def initialize(msg="Address not found")
        super
    end
end
