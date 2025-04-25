module Snes
    module CPU
        module Instructions
            class AddressingModes
                ABSOLUTE = :absolute
                ABSOLUTE_INDEXED_LONG = :absolute_indexed_long
                ABSOLUTE_INDEXED_X = :absolute_indexed_x
                ABSOLUTE_INDEXED_Y = :absolute_indexed_y
                ABSOLUTE_INDIRECT = :absolute_indirect
                ABSOLUTE_INDIRECT_LONG = :absolute_indirect_long
                ABSOLUTE_INDEXED_INDIRECT = :absolute_indexed_indirect
                BLOCK_MOVE = :block_move
                DIRECT = :direct
                DIRECT_INDEXED_X = :direct_indexed_x
                DIRECT_INDEXED_Y = :direct_indexed_y
                DIRECT_INDEXED_INDIRECT = :direct_indexed_indirect
                DIRECT_INDIRECT = :direct_indirect
                DIRECT_INDIRECT_INDEXED = :direct_indirect_indexed
                DIRECT_INDIRECT_INDEXED_LONG = :direct_indirect_indexed_long
                DIRECT_INDIRECT_LONG = :direct_indirect_long
                IMPLIED = :implied
                IMPLIED_ACCUMULATOR = :implied_accumulator
                IMMEDIATE_8BIT = :immediate_8bit
                IMMEDIATE_INDEX_FLAG = :immediate_index_flag
                IMMEDIATE_MEMORY_FLAG = :immediate_memory_flag
                RELATIVE = :relative
                RELATIVE_LONG = :relative_long
                STACK_RELATIVE = :stack_relative
                STACK_RELATIVE_INDIRECT_INDEXED = :stack_relative_indirect_indexed
            end
        end
    end
end


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