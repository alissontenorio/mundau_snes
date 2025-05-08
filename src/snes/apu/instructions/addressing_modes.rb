module Snes
    module APU
        module Instructions
            class AddressingMode
                ABSOLUTE = :absolute # check if this LONG
                DIRECT_PAGE = :direct_page
                DIRECT_PAGE_INDEXED = :direct_page_indexed
                DIRECT_PAGE_INDEXED_POST_INCREMENTED = :direct_page_indexed_post_incremented
                INDIRECT_INDEXED = :indirect_indexed
                INDEXED_INDIRECT = :indexed_indirect
                IMMEDIATE = :immediate
                RELATIVE = :relative

                freeze
            end
        end
    end
end