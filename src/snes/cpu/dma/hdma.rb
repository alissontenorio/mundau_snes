require 'singleton'

# Horizontal DMA (HDMA) performs a small transfer after each horizontal scan
# (while the CRT beam is preparing to draw the next row).
# This avoids interrupting the CPU for long intervals but transfers are limited to 4 bytes per scanline
#
# The H-DMA can interrupt even during the transfer by the GPDMA, which means
# HDMA has higher priority than GPDMA (page 2-17-1 SNES development book 1)
module Snes
    module CPU
        module DMA
            # The DMA for the SNES to transfer the data between
            # "BusA Address" in the CPU (0000000 ~ 0FFFFFF) and
            # "BusB Address" in the S-PUU (0002100 ~ 00021FF),
            # which has 8 channels total.
            class HDMA
                include Singleton

                # Special DMA which can transfer data automatically, synchronizzing with H-Blank.
                # The S-PPU settings can be varied by each horizontal scanline and special effects can be added to
                # the picture
                #
                # Transfers the data from the A-Bus memory (CPU memory) to the S-PPU register. There are two
                # kinds of addressing modes on the A-Bus side:
                # - Absolute
                # - Indirect addressing.
                # Either type of addresssing can be set by each channel.
                #
                # There are two kinds of data transfer. Transfer a set of data:
                # - During each horizontal blanking period
                # - Every certain number of horizontal blanks

            end
        end
    end
end