#### Sprite:
# An area on memory called Object Attribute Memory (OAM) stores a table with references of up to 128 sprites with these properties [12]:
#
#     Size: The PPU can combine up to 16 small tiles in the form of a 4x4 tiles quadrant to build a sprite.
#     Tile References: The value points to the tiles used to draw the sprite.
#     Screen Position. Only sprites positioned inside the visible area will be rendered.
#     Priority: Since multiple layers overlap each other, the graphic with the highest priority will be shown, this is also determined by the background mode in use.
#     Colour palette slot, allowing 9 slots to choose from CGRAM.
#     X/Y Flip.
#
# The S-PPU can draw up to 32 sprites per scanline, overflowing this will only make the S-PPU discard the ones with the lowest priority.