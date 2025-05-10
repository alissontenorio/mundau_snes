require 'singleton'
require 'thread'

# 8-bit ‘B Bus’ controlled by the S-PPU: Connects the cartridge, CPU, WRAM, S-PPU and the Audio CPU
# See images/snes_simple_archtecture
#
# O barramento de endereços B é um barramento de 16 bits que a Cpu utiliza para acessar registradores de I/O do Snes,
# e é utilizado principalmente para a comunicação com a PPU e a APU.
# https://www.manualdocodigo.com.br/curso-assembly-snes-mega-parte57/
module Snes
    module Bus
        # 8-bits wide
        class Bus
            include Singleton

            FRAME_BUFFER = Queue.new
            PPU_ADDRESS_QUEUE = Queue.new

            attr_accessor :ppu, :apu

            def setup(debug = false)
                @ppu_mutex = Mutex.new
                @apu_mutex = Mutex.new
                @ppu = nil
                @apu = nil

                @debug = debug
            end

            def set_frame_buffer(buffer)
                FRAME_BUFFER.clear
                FRAME_BUFFER << buffer
            end

            def get_frame_buffer
                FRAME_BUFFER.pop(true) rescue nil # `pop(true)` = non-blocking pop; returns nil if no frame available
            end

            def read_ppu(address)
                @ppu_mutex.synchronize do
                    raise "PPU not set on Bus" unless @ppu
                    Snes::PPU::Registers.debug_print(:read, address) if @debug
                    # puts "Reading from PPU register #{address.to_s(16)}"
                    @ppu.read_register(address)
                end
            end

            def write_ppu(address, value)
                @ppu_mutex.synchronize do
                    raise "PPU not set on Bus" unless @ppu
                    Snes::PPU::Registers.debug_print(:write, address, value) if @debug
                    # puts "Writing to PPU register #{address.to_s(16)} with value #{value.to_s(16)}"
                    @ppu.write(address, value)
                end
            end

            def read_apu(address)
                # Snes::APU::Registers.debug_print(:read, address) if @debug
                @apu_mutex.synchronize do
                    raise "APU not set on Bus" unless @apu
                    # puts "Reading from APU register #{address.to_s(16)}"
                    @apu.read(address)
                end
            end

            def write_apu(address, value)
                # Snes::APU::Registers.debug_print(:write_register, address, value) if @debug
                @apu_mutex.synchronize do
                    raise "APU not set on Bus" unless @apu
                    # puts "Writing to APU register #{address.to_s(16)} with value #{value.to_s(16)}"
                    @apu.write(address, value)
                end
            end
        end
    end
end