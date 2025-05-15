require_relative 'memory/mapper'
require_relative 'cpu/ricoh_5a22'
require_relative 'ppu/ppu'
require_relative 'apu/sony_spc700'
require_relative 'bus/bus'
require_relative 'cpu/wdc_65816'
require_relative 'cpu/internal_cpu_registers'
require_relative '../exceptions/cartridge_exceptions'
require_relative '../cartridge/cartridge'
require_relative '../cartridge/cartridge_builder'
# require_relative '../utils/nanosleep'
# require_relative '../utils/nanosleep'

module Snes
    class Console
        # include Utils::FileOperations
        include Singleton
        # include Utils::NanoSleep

        LOW_CLOCK_SPEED = 1.79    # 12-clocks per cycle
        MEDIUM_CLOCK_SPEED = 2.68 # 8-clocks per cycle) (200ns)
        HIGH_CLOCK_SPEED = 3.58   # 6-clocks per cycle) (120ns)

        # Ricoh_CPU = Snes::CPU::Ricoh_5A22.instance

        # ToDo: Maybe remove SRAM from here, since its from cartridge
        SRAM = Array.new(32768, 0) # 32 KB # Max access up to 32767 (0x7FFF)
        RAM = Array.new(131072, 0) # 128 KB # Max access up to 131071 (0x1FFFF)

        FPS = 1000
        CYCLES_PER_FRAME_NORMAL = (3_580_000.0 / FPS).to_i # 59,666
        CYCLES_PER_FRAME_SLOW   = (2_680_000.0 / FPS).to_i # 44,666
        
        attr_accessor :m_map, :cartridge, :cpu_thread, :ppu_thread, :bus

        def setup(debug = false)
            @cartridge = nil
            @m_map = nil
            @debug_cpu = debug
            @debug_apu = debug
            @debug_ppu = debug
            @debug_bus = debug
            # @debug_cpu = false
            # # @debug_apu = false
            # @debug_ppu = false
            # @debug_bus = false

            @running = true
            @bus = Snes::Bus::Bus.instance
            @bus.setup(@debug_bus)

            @shutdown_mutex = Mutex.new
            @shutdown = false

            @start_mutex = Mutex.new
            @start_condition = ConditionVariable.new
            @cpu_ready = false
            @ppu_ready = false
            @apu_ready = false
            @bus_ready = false
        end

        def insert_cartridge(rom_raw)
            cartridge = Rom::CartridgeBuilder.new(rom_raw).get_cartridge
            @cartridge = cartridge
            @m_map = Snes::Memory::Mapper.new(@cartridge, RAM, SRAM, @bus, @debug_cpu)
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
            puts "Run cpu" if @debug_cpu
            core = Snes::CPU::WDC65816.new
            # internal_cpu_registers = Snes::CPU::InternalCPURegisters.new
            # @m_map.set_internal_cpu_registers(internal_cpu_registers)
            core.setup(@m_map, @cartridge.emulation_vectors, @cartridge.native_vectors, @debug_cpu)
            # core.setup(@m_map, @cartridge.emulation_vectors[:reset], false)
            sleep_time = (1.0 / FPS)
            # sleep_time = (1.0 / 5)

            wait_until_ready # Wait all threads setup
            sleep(0.1)

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

                # sleep_ns(279 * core.cycles)

                sleep(sleep_time) # To simulate frame rate for CPU

                # stop if test_counter > 4
            end
        end

        def run_ppu
            puts "Run ppu" if @debug_ppu
            ppu = Snes::PPU::PPU.new
            ppu.setup(@debug_ppu)
            sleep_time = (1.0 / FPS)
            @bus.ppu = ppu

            wait_until_ready # Wait all threads setup

            while @running
                ppu.step
                @bus.set_frame_buffer(ppu.get_frame_buffer)
                # sleep_ns(186 * cycles)
                sleep(sleep_time) # To simulate frame rate for PPU
            end
        end

        def run_apu
            puts "Run apu" if @debug_apu
            apu = Snes::APU::SPC700.new
            apu.setup(@bus, @debug_apu)
            sleep_time = (3 / FPS)
            # sleep_callback = -> { sleep(1/2) }
            @bus.apu = apu

            wait_until_ready # Wait all threads setup

            apu.boot do
                sleep(sleep_time)
                # $stdout.flush if @debug_apu
            end

            # while @running
            #     # sleep_ns(186 * cycles)
            #     apu.step do
            #         sleep(sleep_time)
            #     end
            # end
        end

        def get_frame_buffer
            @bus.get_frame_buffer
        end

        def execute_cpu_instruction(core)
            # print "\e[2J\e[f" if @debug_cpu # clear screen
            if @debug_cpu
                puts core.inspect
                $cpu_logger.debug("--------------------------")
                $cpu_logger.debug("Fetch decode execute start")
                $cpu_logger.debug("#{core.inspect}")
            end
            core.fetch_decode_execute
            if @debug_cpu
                # $cpu_logger.debug("Cycles: #{core.cycles}\n")
                $cpu_logger.debug("\n")
                puts
                $stdout.flush
            end
        end

        def with_thread_cleanup
            yield
        ensure
            turn_off
        end

        def turn_on
            @shutdown = false

            raise CartridgeNotInsertedError.new unless @cartridge

            cpu_thread = Thread.new {
                puts "Starting CPU thread with run_cpu"

                with_thread_cleanup do
                    run_cpu
                end
            }

            # ppu_thread = Thread.new {
            #     puts "Starting PPU thread with run_ppu"
            #
            #     with_thread_cleanup do
            #         run_ppu
            #     end
            # }

            apu_thread = Thread.new {
                puts "Starting APU thread with run_apu"

                with_thread_cleanup do
                    run_apu
                end
            }

            cpu_thread.report_on_exception = true
            # ppu_thread.report_on_exception = true
            apu_thread.report_on_exception = true
            cpu_thread.abort_on_exception = false
            cpu_thread.name = "CPU Thread"
            # ppu_thread.abort_on_exception = false
            # ppu_thread.name = "PPU Thread"
            apu_thread.abort_on_exception = false
            apu_thread.name = "APU Thread"

            Thread.new do
                @start_mutex.synchronize do
                    # Set all threads to ready (example: mark readiness flags to true)
                    @cpu_ready = true
                    @ppu_ready = true
                    @apu_ready = true

                    # Once all threads are ready, signal them to continue
                    @start_condition.broadcast
                end
            end
        end

        def turn_off
            puts "Turning off"
            @shutdown_mutex.synchronize do
                return if @shutdown
                @shutdown = true

                Thread.list.each do |thread|
                    if thread == Thread.current
                        puts "\e[31m#{thread.name} killed\e[0m - Original Raise" if @debug and thread.name
                        next
                    end

                    case thread.name
                    when 'CPU Thread', 'PPU Thread', 'APU Thread'
                        if thread.alive?
                            begin
                                # Give thread a chance to finish/log (e.g., exception printing)
                                thread.join(0.2)
                            rescue => e
                                # raise e
                                puts "Error while joining thread #{thread.name}: #{e.message}" if @debug
                            ensure
                                thread.kill if thread.alive? # force kill if it didn’t finish
                                puts "\e[31m#{thread.name} killed\e[0m" if @debug and thread.name
                            end
                        end
                    end
                end
            end

            @cartridge = nil
            @m_map = nil
        end

        def remove_cartridge
            @cartridge = nil
            @m_map = nil
            @shutdown = false
        end

        private

        def wait_until_ready
            # Wait until all threads are ready
            @start_mutex.synchronize do
                # Each thread will wait until all readiness flags are true
                @start_condition.wait(@start_mutex) until @cpu_ready && @ppu_ready && @apu_ready
            end
        end
    end
end