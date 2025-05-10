class APUOpcodeNotImplementedError < NotImplementedError
    def initialize(opcode)
        $apu_logger.error("#{self.class.name}: Opcode 0x%02X not implemented" % opcode)
        # $apu_logger.flush if $apu_logger.respond_to?(:flush)
        super("Opcode 0x%02X not implemented" % opcode)
    end
end