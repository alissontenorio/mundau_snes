require 'singleton'

# 8-bit ‘B Bus’ controlled by the S-PPU: Connects the cartridge, CPU, WRAM, S-PPU and the Audio CPU
# See images/snes_simple_archtecture
#
# O barramento de endereços B é um barramento de 16 bits que a Cpu utiliza para acessar registradores de I/O do Snes,
# e é utilizado principalmente para a comunicação com a PPU e a APU.
# https://www.manualdocodigo.com.br/curso-assembly-snes-mega-parte57/
module Snes
    module Bus
        # 8-bits wide
        class BusB
            include Singleton
        end
    end
end