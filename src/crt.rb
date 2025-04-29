require 'gosu'

class CRTGameWindow < Gosu::Window
    def initialize
        super 640, 480
        self.caption = "CRT Effect"
    end

    def update
        # Game logic goes here
    end

    def draw
        # Draw background
        Gosu.draw_rect(0, 0, 640, 480, Gosu::Color::WHITE)

        # Simulate scanlines (dark every other line)
        (0..480).step(2) do |y|
            Gosu.draw_rect(0, y, 640, 1, Gosu::Color.new(50, 0, 0, 0))
        end
    end
end

CRTGameWindow.new.show