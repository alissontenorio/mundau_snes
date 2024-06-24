'''
+----------------------+                     +--------------------+
|    Game Cartridge    |                     |                    |
|                      |                     |    WRAM            |
|                      |                     |                    |
|     +------------+   |         Bus A       |                    |
|     |            |   |               +-----|                    |
|     |   Mask     |   |               |     +--------------------+
|     |   ROM      |   |               |
|     |            |---|---------------|
|     |            |   |               |
|     +------------+   |               |
|                      |           +----------------+
|                      |           |                |
|                      |           |  Ricoh 5A22    |
+----------------------+           |                |
                                   |                |
                                   +----------------+
'''

# 24-bit ‘A Bus’ controlled by the CPU: Connects the cartridge, CPU and WRAM.
# Access up to 16 MB worth of data
#
# O barramento de endereços A é um barramento de 24 bits que a Cpu utiliza para
# acessar tod o mapa de memória do Snes.
#
# https://www.manualdocodigo.com.br/curso-assembly-snes-mega-parte57/
module Snes
    module Bus
        # The maximum area of the A-Bus which can be used in one channel is limited in one bank (65.536 bytes)
        # In case of spreading over more than 2 banks, it is necessary to use more than 2 channels or transfer twice
        # One A-Bus address basically is increased every time 1 byte of data is transferred. However, it can be
        # decreased or fixed depending on the settings (d3 and d4 of register <43X0H>)
        class BusA < Utils::Singleton

        end
    end
end