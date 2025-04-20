# The region in VRAM where the background layers are configured is called Tilemap and is structured as a table (continuous values in memory)
#
#
# Each entry in the Tilemap contains the following attributes:
#
#     Vertical & Horizontal Flip values.
#     Priority (either 0 or 1).
#     Palette reference from CRAM.
#     Tile reference.