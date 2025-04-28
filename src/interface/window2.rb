#!/usr/bin/env ruby

require 'fox16'
require 'fox16/colors'

include Fox

class ImageWindow < FXMainWindow
    ANIMATION_TIME = 100

    def initialize(app)
        @width, @height = 256, 240

        # Invoke base class initializer first
        super(app, "Image Application", :opts => DECOR_ALL, :width => @width, :height => @height)


        @canvas = FXCanvas.new(self, :opts => LAYOUT_FILL)
        @canvas.connect(SEL_PAINT, method(:onCanvasRepaint))

        # Create images with dithering
        @ppu_image = FXImage.new(getApp(), nil, IMAGE_OWNED|IMAGE_SHMI|IMAGE_SHMP, @width, @height)

        pixels = Array.new(256 * 240, FXRGB(255, 255, 255))
        @ppu_image.setPixels(pixels, 0, @width, @height)
    end

    def update_screen
        pixels = Array.new(256 * 240, FXRGB(0, 0, 255))
        @ppu_image.setPixels(pixels, 0, @width, @height)
        @ppu_image.render
        @canvas.update
    end

    def onCanvasRepaint(sender, sel, event)
        dc = FXDCWindow.new(@canvas, event)  # Drawing context for the canvas during repaint
        dc.drawImage(@ppu_image, 0, 0)        # Draw PPU image at (0,0)
        dc.end
    end

    def create
        # Create the windows
        super

        # Create images
        @ppu_image.create

        # Make the main window appear
        show(PLACEMENT_SCREEN-100)

        @timer = app.addTimeout(ANIMATION_TIME, :repeat => true) do
            update_screen
        end
    end
end
