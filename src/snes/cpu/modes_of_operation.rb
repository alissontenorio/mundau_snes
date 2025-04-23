# 10 different modes of operation
# CPU always starts in ‘emulation’ mode (pure 6502)
#
#
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