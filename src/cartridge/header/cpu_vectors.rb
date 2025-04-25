require_relative '../../utils/endian'

# # Find mem addr of interrupt code
# def parse_header_interrups(self, rom_byte_array, start_address):
#     addr = start_address
#     self.native_cop_int_addr   = get_two_bytes_little_endian(rom_byte_array[addr + 38], rom_byte_array[addr + 39])
#     self.native_brk_int_addr   = get_two_bytes_little_endian(rom_byte_array[addr + 40], rom_byte_array[addr + 41])
#     self.native_abort_int_addr = get_two_bytes_little_endian(rom_byte_array[addr + 42], rom_byte_array[addr + 43])
#     self.native_reset_int_addr = get_two_bytes_little_endian(rom_byte_array[addr + 44], rom_byte_array[addr + 45])
#     self.native_irq_int_addr   = get_two_bytes_little_endian(rom_byte_array[addr + 46], rom_byte_array[addr + 47])
#     # co processor enable
#     self.cop_int_addr   = get_two_bytes_little_endian(rom_byte_array[addr + 54], rom_byte_array[addr + 55])
#     self.abort_int_addr = get_two_bytes_little_endian(rom_byte_array[addr + 56], rom_byte_array[addr + 57])
#     self.nmi_int_addr   = get_two_bytes_little_endian(rom_byte_array[addr + 58], rom_byte_array[addr + 59])
#     # execution begins at reset code (entry point of game)
#     self.reset_int_addr = get_two_bytes_little_endian(rom_byte_array[addr + 60], rom_byte_array[addr + 61])
#     self.irq_int_addr   = get_two_bytes_little_endian(rom_byte_array[addr + 62], rom_byte_array[addr + 63]) # TODO BRK

# CPU vectors

# When an interrupt occurs, the address of the interrupt handler is read from the vector table in bank $00. The vector used is determined by the type of interrupt and the current CPU mode. Vectors are all 16-bit and the target bank is forced to $00.
#
# 65C816 native mode vectors
# Vector 	Address 	Examples
# COP 	    $FFE4-FFE5 	COP instruction
# BRK 	    $FFE6-FFE7 	BRK instruction
# (ABORT) 	$FFE8-FFE9 	(Unused on 5A22 S-CPU)
# NMI 	    $FFEA-FFEB 	NMITIMEN vblank interrupt, or 5A22 /NMI input
# (none) 	$FFEC-FFED
# IRQ 	    $FFEE-FFEF 	NMITIMEN H/V timer interrupt, or external interrupt (5A22 /IRQ input)
#
# 6502 emulation mode vectors
# Vector 	Address 	Examples
# COP 	    $FFF4-FFF5 	COP instruction
# (none) 	$FFF6-FFF7
# (ABORT) 	$FFF8-FFF9 	(Unused on 5A22 S-CPU)
# NMI 	    $FFFA-FFFB 	5A22 /NMI input
# RESET 	$FFFC-FFFD 	5A22 /RESET (CPU always resets into 6502 mode)
# IRQ/BRK 	$FFFE-FFFF 	BRK instruction, or external interrupt (5A22 /IRQ input)

# Resumo
#
# NMI (V‑Blank) é o coração do loop de frame do SNES.
#
# IRQ (H/V) permite efeitos de scanline e temporização intra‑frame.
#
# BRK/COP são armadilhas de software; ABORT trata falhas de bus.


# 1. NMI (Non‑Maskable Interrupt)
# Fonte: Pulso de V‑Blank, gerado pela PPU logo após a última linha visível (scanline 224 ou 239, conforme modo vídeo).

# 2. IRQ (Interrupt Request)
# Gerados por PPU, SPC700, DMA, linha de IRQ
# Fonte: Timer de scanline (H‑IRQ) Uso: Efeitos de linha (HDMA mid‑frame), split‑scroll, status bar.
# Fonte: Timer de V‑line (V‑IRQ) Uso: Eventos menos críticos dentro do frame (ex.: fade‑out parcial, música).

# 3. RESET
# Gerada por: Linha /RES externa, botão Power‑On, watchdog
# Fonte: RESET (CPU always resets into 6502 mode)

# 4. BRK
# Fonte: BRK instruction Uso: Pontos de depuração; também usado por alguns kernels para traps de sistema.

# 5. COP
# Fonte: Instrução COP #imm Uso: Chamadas de sistema em ambiente multitarefa (raras em jogos comerciais).
# Na prática, usados por depuradores/emuladores ou por SOs caseiros (ex.: Nintendo Disk System BIOS no Famicom).

# 6. ABORT
# Gerada por: Sinal interno do bus‑error

module Rom
    # Interrupt Vectors
    class CpuVectors
        class << self
            include Utils::Endian

            def get_vectors(raw_rom, header_start_addr)
                # Should be FFE4 or 7FE4 (if hirom or lorom)
                addr = header_start_addr + 36
                [native_mode_vectors(raw_rom, addr), emulation_mode_vectors(raw_rom, addr)]
            end

            # WDC 65C816
            def native_mode_vectors(raw_rom, addr)
                {
                    cop: little_endian_bin(raw_rom[addr].ord.to_s(16), raw_rom[addr+1].ord.to_s(16)),
                    brk: little_endian_bin(raw_rom[addr+2].ord.to_s(16), raw_rom[addr+3].ord.to_s(16)),
                    abort: little_endian_bin(raw_rom[addr+4].ord.to_s(16), raw_rom[addr+5].ord.to_s(16)),
                    nmi: little_endian_bin(raw_rom[addr+6].ord.to_s(16), raw_rom[addr+7].ord.to_s(16)),
                    none: little_endian_bin(raw_rom[addr+8].ord.to_s(16), raw_rom[addr+9].ord.to_s(16)),
                    irq: little_endian_bin(raw_rom[addr+10].ord.to_s(16), raw_rom[addr+11].ord.to_s(16))
                }
            end

            # Ricoh 6502
            def emulation_mode_vectors(raw_rom, addr)
                {
                    cop: little_endian_bin(raw_rom[addr+16].ord.to_s(16), raw_rom[addr+17].ord.to_s(16)),
                    none: little_endian_bin(raw_rom[addr+18].ord.to_s(16), raw_rom[addr+19].ord.to_s(16)),
                    abort: little_endian_bin(raw_rom[addr+20].ord.to_s(16), raw_rom[addr+21].ord.to_s(16)),
                    nmi: little_endian_bin(raw_rom[addr+22].ord.to_s(16), raw_rom[addr+23].ord.to_s(16)),
                    reset: little_endian_bin(raw_rom[addr+24].ord.to_s(16), raw_rom[addr+25].ord.to_s(16)),
                    irq_brk: little_endian_bin(raw_rom[addr+26].ord.to_s(16), raw_rom[addr+27].ord.to_s(16))
                }
            end
        end
    end
end