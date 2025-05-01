require_relative 'memory/mapper'
require_relative 'cpu/ricoh_5a22'
require_relative 'ppu/ppu'
require_relative 'bus/bus'
require_relative 'cpu/wdc_65816'
require_relative 'cpu/internal_cpu_registers'
require_relative '../exceptions/cartridge_exceptions'
require_relative '../cartridge/cartridge'
require_relative '../cartridge/cartridge_builder'

module Snes
    class Console
        # include Utils::FileOperations
        include Singleton

        LOW_CLOCK_SPEED = 1.79    # 12-clocks per cycle
        MEDIUM_CLOCK_SPEED = 2.68 # 8-clocks per cycle) (200ns)
        HIGH_CLOCK_SPEED = 3.58   # 6-clocks per cycle) (120ns)

        # Ricoh_CPU = Snes::CPU::Ricoh_5A22.instance

        # ToDo: Maybe remove SRAM from here, since its from cartridge
        SRAM = Array.new(32768, 0) # 32 KB # Max access up to 32767 (0x7FFF)
        RAM = Array.new(131072, 0) # 128 KB # Max access up to 131071 (0x1FFFF)

        FPS = 60
        CYCLES_PER_FRAME_NORMAL = (3_580_000.0 / FPS).to_i # 59,666
        CYCLES_PER_FRAME_SLOW   = (2_680_000.0 / FPS).to_i # 44,666



        attr_accessor :m_map, :cartridge, :cpu_thread, :ppu_thread, :bus

        def setup(debug = false)
            @cartridge = nil
            @m_map = nil
            @debug = debug

            @running = true
            @bus = Snes::Bus::Bus.instance
            @bus.setup
        end

        def insert_cartridge(rom_raw)
            cartridge = Rom::CartridgeBuilder.new(rom_raw).get_cartridge
            @cartridge = cartridge
            @m_map = Snes::Memory::Mapper.new(@cartridge, RAM, SRAM, @bus, @debug)
        end

        def print_cartridge_header
            # ToDo: Check if Cartridge is inserted
            @cartridge.print
            puts "#{@cartridge.cartridge_type}"
        end

        def current_memory_mapper
            @m_map
        end

        def stop
            @running = false
        end

        # def run_emulator
        #     loop do
        #         frame_start = Time.now
        #
        #         CYCLES_PER_FRAME_NORMAL.times do
        #             cpu.execute_one_instruction
        #             # cpu.update_timers
        #             # cpu.ppu.step
        #             # etc.
        #         end
        #
        #         elapsed = Time.now - frame_start
        #         sleep_time = (1.0 / FPS) - elapsed
        #         sleep(sleep_time) if sleep_time > 0
        #     end
        # end

        def run_cpu
            puts "Run cpu" if @debug
            core = Snes::CPU::WDC65816.new
            internal_cpu_registers = Snes::CPU::InternalCPURegisters.new
            @m_map.set_internal_cpu_registers(internal_cpu_registers)
            core.setup(@m_map, @cartridge.emulation_vectors[:reset], internal_cpu_registers, @debug)

            # test_counter = 0
            while @running
                # CPU execution loop
                execute_cpu_instruction(core)
                # This way it can continue to next instruction
                # begin
                #     execute_cpu_instruction
                # rescue => e
                #     puts "An error occurred while executing instruction:"
                # end

                # sleep_time = (1.0 / 60)
                sleep_time = (1.0 / 5)
                sleep(sleep_time) # To simulate frame rate for CPU
                # stop if test_counter > 4
            end
        end

        def run_ppu
            puts "Run ppu" if @debug
            ppu = Snes::PPU::PPU.new
            ppu.setup(@debug)
            @bus.ppu = ppu

            while @running
                ppu.step
                @bus.set_frame_buffer(ppu.get_frame_buffer)
                sleep_time = (1.0 / 60)
                sleep(sleep_time) # To simulate frame rate for PPU
            end
        end

        def get_frame_buffer
            @bus.get_frame_buffer
        end

        def execute_cpu_instruction(core)
            puts core.inspect if @debug
            $logger.debug("--------------------------") if @debug
            $logger.debug("Fetch decode execute start") if @debug
            $logger.debug("#{core.inspect}") if @debug
            core.fetch_decode_execute
            $logger.debug("Cycles: #{core.cycles} ") if @debug
            puts if @debug
            $logger.debug(" ") if @debug
            $stdout.flush if @debug
        end

        def turn_on
            raise CartridgeNotInsertedError.new unless @cartridge

            begin
                # Start CPU thread
                cpu_thread = Thread.new {
                    begin
                        run_cpu
                    rescue => e
                        puts "An error occurred while executing instruction: #{e.message}" if @debug
                        raise e
                    ensure
                        turn_off
                        puts "CPU Thread has finished or was killed." if @debug
                    end
                }

                # Start PPU thread
                ppu_thread = Thread.new {
                    begin
                        run_ppu
                    ensure
                        turn_off
                        puts "PPU Thread has finished or was killed." if @debug
                    end
                }

                cpu_thread.report_on_exception = true
                ppu_thread.report_on_exception = true
                cpu_thread.abort_on_exception = false
                cpu_thread.name = "CPU Thread"
                ppu_thread.abort_on_exception = false
                ppu_thread.name = "PPU Thread"

                # cpu_thread.join
                # ppu_thread.join
            rescue => e
                puts "An error occurred while starting threads: #{e.message}" if @debug
                # puts "An error occurred while starting threads:"
                puts e.backtrace if @debug
                stop
            end
        end

        def turn_off
            Thread.list.each do |thread|
                thread.kill if thread.alive? && thread.name == 'PPU Thread' && thread != Thread.current
                thread.kill if thread.alive? && thread.name == 'CPU Thread' && thread != Thread.current
            end

            @cartridge = nil
            @m_map = nil
        end

        def remove_cartridge
            @cartridge = nil
            @m_map = nil
        end
    end
end