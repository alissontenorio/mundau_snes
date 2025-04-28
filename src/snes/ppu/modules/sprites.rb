class PPU::Sprite
    def initialize(ppu)
        @ppu = ppu
        @oam = Array.new(128) { SpriteEntry.new }
        @scanline_sprites = []
    end

    def evaluate(vcounter)
        @scanline_sprites.clear
        @oam.each do |sprite|
            if sprite.visible_on_line?(vcounter)
                @scanline_sprites << sprite
                break if @scanline_sprites.size >= 32
            end
        end
    end

    def pixel(x, y)
        # Find the top sprite pixel at (x, y), respecting priority
    end
end