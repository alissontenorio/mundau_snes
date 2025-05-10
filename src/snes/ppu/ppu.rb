require_relative 'registers'
# require 'singleton'

module Snes::PPU
    class PPU
        # include Singleton

        attr_accessor :registers

        def setup(debug = false)
            # Initializes registers and sets the initial state of the PPU
            @registers = Snes::PPU::Registers
            @scanline = 0  # Scanline counter for vertical scrolling
            @frame_count = 0  # Frame counter to simulate video refresh
            @oam = []  # Object Attribute Memory (sprites)
            @bg_scroll = { BG1: { x: 0, y: 0 }, BG2: { x: 0, y: 0 } }  # Background scroll positions
            @palette = Array.new(256, 0)  # Placeholder for the color palette (256 colors)

            @force_blank = false
            @brightness = 0
            @frame_buffer = Array.new(256 * 240, [0, 0, 0])   # Simple frame buffer (256x240 resolution for NTSC)
            @debug = debug
        end

        def get_frame_buffer
            @frame_buffer
        end

        # Call this method to update the frame buffer
        def render_frame
            # This simulates rendering a frame; in a real implementation, you'd update this buffer
            # with the actual pixel data from backgrounds, sprites, etc.
            (0...@frame_buffer.size).each { |i| @frame_buffer[i] = [rand(0..255), rand(0..255), rand(0..255)] }  # Simulating random pixels
        end

        # Method to read a register's value
        def read_register(address)
            # puts "PPU read register: #{address.to_s(16)}" if address == 0x2140
            # puts "PPU read register: #{address.to_s(16)}" if address == 0x2141
            # puts "PPU read register: #{address.to_s(16)}"
            @registers.access(:read, address)
        end

        # Method to write a value to a register
        def write(address, value)
            # puts "PPU write register: #{address.to_s(16)} = #{value.to_s(16)}" if address == 0x2100
            # Bits 0–3 (lowest 4 bits): set screen brightness (from 0 to 15).
            # Bit 7 (highest bit): force blank (1 = force screen blank, 0 = normal rendering).
            # Even though the screen is visually blanked, backgrounds, sprites, scrolling, etc., continue to update internally — they're just not shown until you clear the force blank bit.
            @registers.access(:write, address, value)

            if address == 0x2100
                handle_inidisp(value)
            end
        end

        def handle_inidisp(value)
            @force_blank = (value & 0x80) != 0   # Bit 7: Force Blank flag
            @brightness = value & 0x0F           # Bits 0-3: Brightness level
        end

        def blank_screen
            # Fill the frame buffer with black (color 0)
            @frame_buffer.fill([0, 0, 0])
        end

        # This method is called once per PPU cycle to simulate one step of rendering
        def step
            # puts "PPU step" if @debug

            # 1. Advance the scanline (vertical positioning on the screen)
            advance_scanline

            # 2. Handle rendering tasks for the current scanline
            process_rendering unless @force_blank

            # 3. Handle V-blank or other special modes at the right scanline
            handle_vblank if @scanline >= 240

            # 4. Update any necessary registers (e.g., INIDISP, STAT77)
            update_ppu_status if @scanline == 240

            # 4. Handle palette updates (e.g., update CGRAM colors during rendering or V-blank)
            handle_palettes if @scanline >= 240

            # 5. Handle interrupts or other PPU-specific tasks if needed
            handle_interrupts

            # Optional: Increment the frame count (60 frames per second, for example)
            update_frame_count

            # Simulate a single step of the PPU rendering process
            if @force_blank
                blank_screen  # Always black if forced blank
            else
                render_frame  # Normal frame rendering
            end
        end

        private

        # Advances the scanline and triggers vertical blanking if needed
        def advance_scanline
            @scanline += 1
            if @scanline >= 262  # 262 scanlines in a typical NTSC frame
                @scanline = 0
            end
        end

        def process_rendering
            # Rendering process, depends on scanline and mode
            if @scanline >= 240 # Or maybe 239?
                # V-blank period; can trigger specific actions like updating display registers
                write(0x2100, 1)  # Example: update screen display register
            else
                # Handle normal rendering for backgrounds and sprites
                handle_sprite_rendering
                handle_background_rendering
                handle_oam
            end
        end

        # Handle the V-blank process, which occurs when the scanline reaches 240+
        def handle_vblank
            # Handle actions during V-blank (scanline >= 240)
            write(0x213E, 1)  # For example, set STAT77 to indicate V-blank
            handle_interrupts
        end

        def handle_sprite_rendering
            # In a full implementation, we'd use the OAM to handle sprite rendering
            # Here we'll just simulate the handling of sprites (objects)
            if @scanline.between?(0, 239)
                # For each sprite, check if it's within the visible range for the current scanline
                @oam.each do |sprite|
                    if sprite_visible?(sprite)
                        render_sprite(sprite)
                    end
                end
            end
        end

        def sprite_visible?(sprite)
            # Check if the sprite should be visible on the current scanline
            sprite[:y_position] == @scanline
        end

        def render_sprite(sprite)
            # Actual sprite rendering logic (simplified)
            # Here we just simulate writing to the OAM data register
            write(0x2104, sprite[:data])
        end

        def handle_background_rendering
            # Handle background rendering logic here for BG1, BG2, etc.
            # For example, we can update the background scroll registers for BG1, BG2, etc.
            @bg_scroll.each do |bg, scroll|
                write(0x210D, scroll[:x])  # Write horizontal scroll position
                write(0x210E, scroll[:y])  # Write vertical scroll position
            end
        end

        def handle_palettes
            # Example: Manage palette updates (simplified)
            if @scanline == 240
                write(0x2121, @palette[0])  # Write first color to the palette register
            end
        end

        def update_frame_count
            @frame_count += 1
            if @frame_count >= 60  # Assume 60 frames per second for simplicity
                @frame_count = 0
                # Trigger a frame interrupt if necessary
            end
        end

        # Update PPU status registers as needed (e.g., for certain scanlines)
        def update_ppu_status
            # For instance, update STAT77 to reflect that we're in the V-blank
            write(0x213E, 1)
        end

        def handle_interrupts
            # Handle various interrupts based on PPU state
            # For example, triggering a V-blank interrupt
            if @scanline == 240
                trigger_vblank_interrupt
            end
        end

        # Handle Object Attribute Memory (OAM), which stores sprite data
        def handle_oam
            # Process OAM (sprites) for the current scanline
            # This involves checking which sprites are visible on the current scanline
            # and updating OAM accordingly.
        end

        def trigger_vblank_interrupt
            # Simulate a V-blank interrupt
            # In a real system, we would notify the CPU to handle the interrupt
            puts "V-blank interrupt triggered" if @debug
        end
    end
end
