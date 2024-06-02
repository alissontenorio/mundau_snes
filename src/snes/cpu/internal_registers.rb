class InternalRegisters
    # Accumulator
    # 8 or 16 Bit
    @A = 0

    # Index - The index registers. These can be used to reference memory, to pass data to memory, or as counters for loops.
    # 8 or 16 Bit
    @X = 0

    # Same above
    @Y = 0

    # Stack Pointer - The stack pointer, points to the next available(unused) location on the stack.
    @S = 0

    # Data Bank - Data bank register, holds the default bank for memory transfers.
    # 8-bit
    @DBR = 0

    # Direct Page - Direct page register, used for direct page addressing modes. Holds the memory bank address of the data the CPU is accessing.
    @DP = 0

    # PBR - Program Bank - Program Bank, holds the bank address of all instruction fetches.
    # 8-bit
    @PB = 0

    # Processor Status - Holds various important flags, results of tests and 65816 processing states. See below.
    @P = 0

    # Program Counter - Holds the memory address of the current CPU instruction
    @PC = 0
end

# Flags stored in P Register
# Mnemonic 	Value 	Binary Value 	Description
# N 	    #$80 	10000000 	Negative
# V 	    #$40 	01000000 	Overflow
# M 	    #$20 	00100000 	Accumulator register size (native mode only), (0 = 16-bit, 1 = 8-bit)
# X 	    #$10 	00010000 	Index register size (native mode only), (0 = 16-bit, 1 = 8-bit)
# D 	    #$08 	00001000 	Decimal
# I 	    #$04 	00000100 	IRQ disable
# Z 	    #$02 	00000010 	Zero
# C 	    #$01 	00000001 	Carry
# E 			                6502 emulation mode
# B 	    #$10 	00010000 	Break (emulation mode only)


# Addressing Modes
# Mode 	                            Example
# Implied 	                        PHB
# Immediate[MemoryFlag] 	        AND #1 or 2 bytes
# Immediate[IndexFlag] 	            LDX #1 or 2 bytes
# Immediate[8-Bit] 	                SEP #byte
# Relative 	                        BEQ byte (signed)
# Relative long 	                BRL 2 bytes (signed)
# Direct 	                        AND byte
# Direct indexed (with X) 	        AND byte, x
# Direct indexed (with Y) 	        AND byte, y
# Direct indirect 	                AND (byte)
# Direct indexed indirect 	        AND (byte, x)
# Direct indirect indexed 	        AND (byte), y
# Direct indirect long 	            AND [byte]
# Direct indirect indexed long 	    AND [byte], y
# Absolute                          AND 2bytes
# Absolute indexed (with X) 	    AND 2bytes, x
# Absolute indexed (with Y) 	    AND 2bytes, y
# Absolute long 	                AND 3bytes
# Absolute indexed long 	        AND 3bytes, x
# Stack relative 	                AND byte, s
# Stack relative indirect indexed 	AND (byte, s), y
# Absolute indirect 	            JMP (2bytes)
# Absolute indirect long 	        JML [2bytes]
# Absolute indexed indirect 	    JMP/JSR (2bytes,x)
# Implied accumulator 	            INC
# Block move 	                    MVN/MVP byte, byte