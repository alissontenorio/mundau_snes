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
class BusA

end