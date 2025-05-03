require 'ffi'

module LibC
    extend FFI::Library
    ffi_lib FFI::Library::LIBC

    class Timespec < FFI::Struct
        layout :tv_sec, :time_t,     # segundos
               :tv_nsec, :long       # nanossegundos
    end

    attach_function :nanosleep, [Timespec.by_ref, :pointer], :int
end

module Utils
    module NanoSleep
        def sleep_ns(nanoseconds)
            ts = LibC::Timespec.new
            ts[:tv_sec] = 0
            ts[:tv_nsec] = nanoseconds

            LibC.nanosleep(ts, nil)
        end
    end
end


