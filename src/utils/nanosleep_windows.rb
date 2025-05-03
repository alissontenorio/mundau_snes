require 'fiddle'
require 'fiddle/import'

module WinAPI
    extend Fiddle::Importer
    dlload 'kernel32'

    extern 'void Sleep(DWORD)' # Sleep em milissegundos

    extern 'BOOL QueryPerformanceCounter(LARGE_INTEGER*)'
    extern 'BOOL QueryPerformanceFrequency(LARGE_INTEGER*)'
end

module HighPrecisionSleep
    extend self

    FREQ = Fiddle::Pointer.malloc(Fiddle::SIZEOF_LONG_LONG)
    WinAPI.QueryPerformanceFrequency(FREQ)
    PERFORMANCE_FREQUENCY = FREQ[0, Fiddle::SIZEOF_LONG_LONG].unpack1('Q')

    def sleep_ns(nanoseconds)
        target_ticks = (nanoseconds * PERFORMANCE_FREQUENCY) / 1_000_000_000

        start = Fiddle::Pointer.malloc(Fiddle::SIZEOF_LONG_LONG)
        WinAPI.QueryPerformanceCounter(start)
        start_ticks = start[0, Fiddle::SIZEOF_LONG_LONG].unpack1('Q')

        loop do
            current = Fiddle::Pointer.malloc(Fiddle::SIZEOF_LONG_LONG)
            WinAPI.QueryPerformanceCounter(current)
            now_ticks = current[0, Fiddle::SIZEOF_LONG_LONG].unpack1('Q')

            break if now_ticks - start_ticks >= target_ticks
            # Opcional: Yield para evitar 100% CPU (ou Sleep(0))
        end
    end
end