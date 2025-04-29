require 'fox16'

module Interface
    # FXRuby GUI class to integrate Console with the GUI
    class EmulatorWindow < Fox::FXMainWindow
        include Fox

        ANIMATION_TIME = 1

        def initialize(app, console)
            @width, @height = 256, 240

            # Invoke base class initializer first
            super(app, "Mundau Snes", :opts => DECOR_ALL, :width => @width, :height => @height)
            @console = console

            # Menu bar
            menu_bar = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X)

            # File menu
            file_menu = FXMenuPane.new(self)
            FXMenuCommand.new(file_menu, "&New...")
            FXMenuCommand.new(file_menu, "&Open...")
            FXMenuCommand.new(file_menu, "&Close")
            FXMenuCommand.new(file_menu, "&Save")
            FXMenuCommand.new(file_menu, "Save &As...")
            FXMenuSeparator.new(file_menu)
            FXMenuCommand.new(file_menu, "&Print...")
            FXMenuCommand.new(file_menu, "Print &Setup...")
            FXMenuCommand.new(file_menu, "Print Pre&view")
            FXMenuSeparator.new(file_menu)
            FXMenuCommand.new(file_menu, "E&xit", nil, app, FXApp::ID_QUIT)

            # Edit menu
            edit_menu = FXMenuPane.new(self)
            FXMenuCommand.new(edit_menu, "&Undo")
            FXMenuCommand.new(edit_menu, "&Redo")
            FXMenuSeparator.new(edit_menu)
            FXMenuCommand.new(edit_menu, "&Cut")
            FXMenuSeparator.new(edit_menu)
            FXMenuCommand.new(edit_menu, "Change &background color")
            FXMenuCommand.new(edit_menu, "Edit &label")

            # Help menu
            help_menu = FXMenuPane.new(self)
            aboutBox = FXMenuCommand.new(help_menu, "&About...")
            aboutBox.connect(SEL_COMMAND) do |sender, sel, ptr|
                FXMessageBox.information(self, MBOX_OK, "About Canvas",
                                         "Canvas Demo\nTo draw a shape, select a shape on the toolbar and left-click on the canvas.\nTo draw a line, right-drag between shapes.")
            end

            # Recently used files
            @mru_files = FXRecentFiles.new

            # Add a button to simulate turning on the console
            # button = Fox::FXButton.new(self, "Turn On Console")
            # button.connect(SEL_COMMAND) do
            #     @console.turn_on
            # end

            # Attach menus to menu bar titles
            FXMenuTitle.new(menu_bar, "&File", nil, file_menu)
            FXMenuTitle.new(menu_bar, "&Edit", nil, edit_menu)
            FXMenuTitle.new(menu_bar, "&Help", nil, help_menu)

            # Status bar
            FXStatusBar.new(self, LAYOUT_SIDE_BOTTOM|LAYOUT_FILL_X|STATUSBAR_WITH_DRAGCORNER)

            @canvas = FXCanvas.new(self, :opts => Fox::LAYOUT_FILL)
            @canvas.connect(SEL_PAINT, method(:onCanvasRepaint))
            @ppu_image = FXImage.new(getApp(), nil, IMAGE_OWNED|IMAGE_SHMI|IMAGE_SHMP, @width, @height)

            # Resize the canvas when the window is resized
            # @canvas.connect(SEL_CONFIGURE) { |sender, sel, evt|
            #     @ppu_image.create unless @ppu_image.created?
            #     @ppu_image.resize(sender.width, sender.height)
            # }
        end

        def update_screen
            # Get the PPU frame buffer (pixel data) from the console
            frame_buffer = @console&.get_frame_buffer  # Use `get_frame_buffer` from Console

            return if frame_buffer.nil?

            # if turned_off
            #     frame_buffer = Array.new(256 * 240, [0, 0, 0])
            #     (0...frame_buffer.size).each do |i|
            #         # Black and white
            #         # x = rand(0..255)
            #         # frame_buffer[i] = [x, x, x]
            #         # Color
            #         frame_buffer[i] = [rand(0..255), rand(0..255), rand(0..255)]
            #     end
            # end

            # Ensure the frame buffer has the expected size (256 * 240)
            if frame_buffer.nil? || frame_buffer.length != 256 * 240
                puts "Frame buffer has an unexpected size! #{frame_buffer.length}"
                return
            end

            # Prepare the pixel data for FXImage
            pixels = []

            # Convert the frame buffer into an array of packed RGB values
            (0...@width).each do |x|
                (0...@height).each do |y|
                    pixel_r, pixel_g, pixel_b = frame_buffer[y * 256 + x]
                    # Assuming grayscale pixel value, you can adjust this if you want color
                    rgb = FXRGB(pixel_r, pixel_g, pixel_b)  # Grayscale
                    pixels << rgb
                end
            end

            # pixels = Array.new(256 * 240, FXRGB(0, 100, 255))
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
end