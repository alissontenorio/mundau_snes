# According to this site there are three buses
# https://www.manualdocodigo.com.br/curso-assembly-snes-mega-parte2/
#
# A Bus - 24 bits
# B Bus - 16 bits
# Data Bus - 8 bits
#
#
# O barramento de dados é um barramento de 8 bits que a Cpu
# utiliza para enviar e receber dados dos vários elementos do Snes.
# Todos os dados que trafegam entre o cartucho, Ram, PPU, APU, etc, passam por esse barramento.
#
# https://www.manualdocodigo.com.br/curso-assembly-snes-mega-parte57/
module Snes
    module Bus
        class BusData < Utils::Singleton

        end
    end
end