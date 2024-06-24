module Utils
    module FileOperations
        def open_rom(rom_filepath)
            begin
                file = File.open(rom_filepath, 'rb')
                b_array = file.read
                file.close
                b_array
            rescue StandardError => ex
                puts "Error opening the rom #{ex.message}"
            end
        end
    end
end