# Core - Ricoh 5A22 - Based on 6502 CPU - WDC 65C816
class Ricoh5A22
    # 65816 assembly
    # Clock Speed
    # 3.58 MHz during register operations - non-access cycles
    # 2.68 MHz
    # 1.79 MHz when accessing the slowest buses (i.e. the serial/controller port) -

    @BusA = BusA.new # 24-bit general access
    @BusB = BusB.new # 8-bit mostly to register of APU and PPU

    @FastROM = false

    # 8-channel DMA unit

    # Porta de interface para os circuitos do controlador, incluindo ambos acessos serial e paralelo aos dados do controlador
    # Uma porta I/O paralela de 8-bit, que quase não é usada no SNES
    # Circuitos para geração de Interrupção NMI ou V-Blank.
    # Circuitos para geração de Interrupção IRQ ao calcular as posições da tela
    # Uma unidade DMA, suportando dois modos primários:
    # DMA geral, para uma transferência de blocos à uma taxa de 2.68MB/s
    # DMA H-blank, para transferência de pequenos conjuntos de dados no final de cada linha de scan fora do período ativo de exibição.
    # Multiplicação e divisão de registros
end