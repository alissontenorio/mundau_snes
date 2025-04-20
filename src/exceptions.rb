class CartridgeHeaderTypeNotIdentifiedError < StandardError
    def initialize(msg="Couldn't identify the cartridge type (Hirom, Exrom, etc)")
        super
    end
end

class AddressOutOfRangeError < StandardError
    def initialize(bank, offset)
        super("Unknown offset for bank #{bank.to_s(16)}:#{offset.to_s(16)}")
    end
end

class BankOutOfRangeError < StandardError
    def initialize(bank, offset)
        super("Bank out of range for address 0x#{bank.to_s(16).rjust(2, '0').upcase}:0x#{offset.to_s(16).rjust(4, '0').upcase}")
    end
end

class OffsetOutOfRangeError < StandardError
    def initialize(bank, offset)
        super("Offset out of range for address 0x#{bank.to_s(16).rjust(2, '0').upcase}:0x#{offset.to_s(16).rjust(4, '0').upcase}")
    end
end

class LowRamOffsetError < StandardError
    def initialize(offset)
        super("Offset 0x#{offset.to_s(16).rjust(4, '0').upcase} is out of range for Low RAM (expected 0x0000..0x1FFF)")
    end
end