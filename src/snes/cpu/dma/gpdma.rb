# General Purpose DMA performs transfers at any time. The CPU is stopped until the transfer is finished.
#
# The system provides eight channels to set up DMA transfers, thus enabling to dispatch up to eight independent transfers at once
# ToDo: https://en.wikibooks.org/wiki/Super_NES_Programming/DMA_tutorial
module Snes
    module CPU
        module DMA
            # The DMA for the SNES to transfer the data between
            # "BusA Address" in the CPU (0000000 ~ 0FFFFFF) and
            # "BusB Address" in the S-PUU (0002100 ~ 00021FF),
            # which has 8 channels total.
            #
            # CPU process stops automatically during DMA period and restarts after DMA is completed
            class GPDMA < Utils::Singleton
                # Can transfer the data rapidly between 2 types of memory devices:
                # - Memory which can be accessed directly by the CPU (e.g ROM on the game cartridge)
                # - Memory which has to be accessed through the S-PPU, such as the V-RAM

            end
        end
    end
end