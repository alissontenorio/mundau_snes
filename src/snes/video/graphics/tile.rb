# 16x16 pixels
#
# When tiles are stored in memory, these will be compressed depending on how many colours per pixel they need to use.
# The unit of size is bpp (bits per pixel). The minimum value is 2 bpp (where each pixel only occupies two bits in
# memory and has only 4 colours available) while the maximum is 8 bpp, which encodes up to 256 colours
# (at the expense of consuming a whole byte).
#
#
#
#### Tiles:
#  - (8 x 8 pixels) but can also be (16 x 16 pixels)
# When tiles are stored in memory,
# these will be compressed depending on how many colours per pixel they need to use.
# The unit of size is bpp (bits per pixel).
# The minimum value is 2 bpp (where each pixel only occupies two bits in memory and has only 4 colours available)
# while the maximum is 8 bpp, which encodes up to 256 colours (at the expense of consuming a whole byte).
module Video

    class Pixel
        # bpp (bits per pixel) # describes how many colors they can use
        # 2 bpp
        # - Used in all layers of BG mode 0, and for one layer in modes 1, 4 and 5.
        # - Each word of VRAM defines two planes of data for an 8 pixel row
        # - Each pixel has a value of 0-3 to index a palette in CGRAM.
        #
        # 4 bpp
        # - The most common format. Used for all sprites, and in BG modes 1, 2, 3, 5, and 6.
        # - This format is essentially two 2bpp tiles.
        #    Bit planes 0 and 1 are in the first 16 bytes, and a second 16 bytes contains bit planes 2 and 3.
        #    With 4 planes, each pixel can have a value from 0-15 to index a color palette.
        #
        # 8 bpp
        # - Used in BG modes 3 and 4.
        # - This is like two 4bpp tiles, or four 2bpp tiles. 64 bytes per tile
        #     Planes 0, 1 (16 bytes)
        #     Planes 2, 3
        #     Planes 4, 5
        #     Planes 6, 7
        #
        #     With 8 planes, the palette index value ranges from 0-255.
        #
        # 8bpp Direct Color
        # - An alternate mode for BG modes 3 and 4, enabled via CGWSEL.
        # - This is the same data format as 8bpp, but instead of using the result as a palette index, the bits correspond directly to RGB values.
    end


    class Tile
        # Backgrounds and sprites can sometimes work with 16x16 or larger groups of tiles.
        # These are made up of 8x8 pixel tiles, using tiles that are adjacent horizontally (+1) or
        # vertically (+16) in the 16-column layout.
        # size = 8x8 pixels

        # Tiles
        # 2pp - Uses 16 bytes
        # 4pp - 32 bytes
        # 8pp - 64 bytes per tile
    end
end