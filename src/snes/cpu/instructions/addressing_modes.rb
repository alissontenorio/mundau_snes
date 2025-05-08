module Snes
    module CPU
        module Instructions
            # | **Addressing Mode**               | **Syntax Example** | **Effective Bank Source** | **Notes**                                               |
            # | --------------------------------- | ------------------ | ------------------------- | ------------------------------------------------------- |
            # | **Immediate**                     | `LDA #$12`         | *N/A*                     | Constant from instruction stream (not memory access)    |
            # | **Direct Page**                   | `LDA $10`          | **Bank 0**                | `DP + offset`, 16-bit address                           |
            # | **Direct Page,X**                 | `LDA $10,X`        | **Bank 0**                | `DP + offset + X`                                       |
            # | **Direct Page,Y**                 | `LDA $10,Y`        | **Bank 0**                | Rare, same behavior as above                            |
            # | **Absolute**                      | `LDA $1234`        | **Bank 0**                | 16-bit address, upper 8 bits = 0                        |
            # | **Absolute,X**                    | `LDA $1234,X`      | **Bank 0**                | Indexed, but still bank 0                               |
            # | **Absolute,Y**                    | `LDA $1234,Y`      | **Bank 0**                | Same as above                                           |
            # | **Long**                          | `LDA $123456`      | **Explicit (24-bit)**     | Full 24-bit address encoded in instruction              |
            # | **Long,X**                        | `LDA $123456,X`    | **Explicit (24-bit)**     | Same as above, with indexing                            |
            # | **(Direct Page)**                 | `LDA ($10)`        | **DBR**                   | Indirect pointer in DP; final read is in DBR bank       |
            # | **(Direct Page,X)**               | `LDA ($10,X)`      | **DBR**                   | Indexed version of above                                |
            # | **(Direct Page),Y**               | `LDA ($10),Y`      | **DBR**                   | Add Y after indirect lookup                             |
            # | **\[Absolute]**                   | `LDA [$1234]`      | **DBR**                   | Absolute indirect pointer in zero page                  |
            # | **\[Absolute],Y**                 | `LDA [$1234],Y`    | **DBR**                   | Indexed version of above                                |
            # | **Stack Relative**                | `LDA 10,S`         | **Bank 0**                | Effective address = `SP + offset`, stack is in bank 0   |
            # | **(Stack Relative),Y**            | `LDA (10,S),Y`     | **DBR**                   | Indirect pointer from stack, final access in DBR        |
            # | **Program Counter Relative**      | `BRA`, `BEQ`, etc. | **PBR** (code fetch only) | Not memory access                                       |
            # | **Program Counter Relative Long** | `PER`              | **PBR**                   | Also not memory access                                  |
            # | **Absolute Indirect**             | `JMP ($1234)`      | **Bank 0**                | Used for control flow (jump), address fetched in bank 0 |
            # | **Absolute Long Indirect**        | `JMP [$1234]`      | **Explicit**              | Full 24-bit address                                     |
            # | **Absolute Indexed Indirect**     | `JMP ($1234,X)`    | **Bank 0**                | Control flow only                                       |
            # | **Block Move**                    | `MVN`, `MVP`       | **Explicit**              | Source and destination banks are operands               |
            class AddressingMode
                ABSOLUTE = :absolute
                ABSOLUTE_LONG = :absolute_long
                ABSOLUTE_INDEXED_X = :absolute_indexed_x
                ABSOLUTE_INDEXED_Y = :absolute_indexed_y
                ABSOLUTE_LONG_INDEXED_X = :absolute_long_indexed_x
                ABSOLUTE_INDEXED_INDIRECT = :absolute_indexed_indirect
                ABSOLUTE_INDIRECT = :absolute_indirect
                ABSOLUTE_INDIRECT_LONG = :absolute_indirect_long
                BLOCK_MOVE = :block_move
                DIRECT_PAGE = :direct_page
                DIRECT_PAGE_INDEXED_X = :direct_indexed_x
                DIRECT_PAGE_INDEXED_Y = :direct_indexed_y
                DIRECT_PAGE_INDEXED_INDIRECT_X = :direct_page_indexed_indirect_x
                DIRECT_PAGE_INDIRECT = :direct_page_indirect
                DIRECT_PAGE_INDIRECT_LONG = :direct_page_indirect_long
                DIRECT_PAGE_INDIRECT_INDEXED_Y = :direct_page_indirect_indexed_y
                DIRECT_PAGE_INDIRECT_LONG_INDEXED_Y = :direct_page_indirect_long_indexed_y
                IMMEDIATE = :immediate
                IMPLIED = :implied
                PROGRAM_COUNTER_RELATIVE = :program_counter_relative
                PROGRAM_COUNTER_RELATIVE_LONG = :program_counter_relative_long
                STACK_ABSOLUTE = :stack_absolute
                STACK_DIRECT_PAGE_INDIRECT = :stack_direct_page_indirect
                STACK_INTERRUPT = :stack_interrupt
                STACK_PROGRAM_COUNTER_RELATIVE = :stack_program_counter_relative
                STACK_PULL = :stack_pull
                STACK_PUSH = :stack_push
                STACK_RTI = :stack_rti
                STACK_RTL = :stack_rtl
                STACK_RTS = :stack_rts
                STACK_RELATIVE = :stack_relative
                STACK_RELATIVE_INDIRECT_INDEXED_Y = :stack_relative_indirect_indexed_y

                # Documented but needs to check
                ACCUMULATOR = :accumulator

                freeze
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