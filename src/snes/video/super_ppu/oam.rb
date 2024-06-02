# Object Attribute Memory (OAM)
# 544 B OAM (Object Attribute Memory): Contains tables with references of 128 tiles that will be used as Sprites along with their attributes.
#
#
# Stores a table with references of up to 128 sprites with these properties:
#     Size: The PPU can combine up to 16 small tiles in the form of a 4x4 tiles quadrant to build a sprite.
#     Tile References: The value points to the tiles used to draw the sprite.
#     Screen Position. Only sprites positioned inside the visible area will be rendered.
#     Priority: Since multiple layers overlap each other, the graphic with the highest priority will be shown, this is also determined by the background mode in use.
#     Colour palette slot, allowing 9 slots to choose from CGRAM.
#     X/Y Flip.
#
#
# The S-PPU can draw up to 32 sprites per scanline, overflowing this will only make the S-PPU discard the ones with the lowest priority.
