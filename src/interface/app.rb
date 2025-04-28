require 'fox16'
require_relative 'window'

module Interface
    # Main FXRuby Application
    class EmulatorApp < Fox::FXApp
        def initialize(console)
            @console = console
            super("Console Emulator", "FXRuby")
        end

        def create
            main = EmulatorWindow.new(self, @console)
            # main = EmulatorWindow.new(self)
            super
        end

        # def start
        #     # puts "Starting the app..."
        #     # xx = Thread.new do
        #     #     loop do
        #     #         # Check if there are messages from the Console threads
        #     #         frame_buffer = @console&.get_frame_buffer
        #     #         puts "Received message from Console"
        #     #
        #     #         # Here, you can trigger GUI updates based on message
        #     #         # For example, updating a label or triggering a UI refresh
        #     #     end
        #     # end
        #     # puts "Here"
        #     # xx.join
        #     run
        # end
    end
end