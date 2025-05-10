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

class CPUOpcodeNotImplementedError < NotImplementedError
    def initialize(opcode)
        $cpu_logger.error("#{self.class.name}: Opcode 0x%02X not implemented" % opcode)
        # $cpu_logger.flush if $apu_logger.respond_to?(:flush)
        super("Opcode 0x%02X not implemented" % opcode)
    end
end