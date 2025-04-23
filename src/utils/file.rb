module Utils
    module FileOperations
        def open_rom(rom_filepath)
            begin
                File.open(rom_filepath, 'rb') { |file| file.read }
            rescue StandardError => ex
                puts "Error opening the rom #{ex.message}"
            end
        end
    end
end