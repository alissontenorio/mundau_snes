# Renders graphics (tiles) and applies transformations on them (rotation and scaling).

# Separation of ppu1 and ppu2, from the programming point of view,
# is redundant since both chips are virtually treated as one.

#
#

# draws graphics using 2D tiles (8 x 8 pixels) but can also be (16 x 16 pixels)
# tiles are arranged in rows of 16 columns
#
#     64 KB VRAM (Video RAM):
#        - Stores tiles and maps (tables) used to build background layers.
#     512 B CGRAM (Colour Graphics RAM):
#        - Fits 512 colour palette entries, each entry has the size of a word (16 bits).
#     544 B OAM (Object Attribute Memory):
#        - Contains tables with references of 128 tiles that will be used as Sprites along with their attributes.
#
#
#


