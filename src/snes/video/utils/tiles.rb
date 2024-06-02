# 16x16 pixels
#
# When tiles are stored in memory, these will be compressed depending on how many colours per pixel they need to use.
# The unit of size is bpp (bits per pixel). The minimum value is 2 bpp (where each pixel only occupies two bits in
# memory and has only 4 colours available) while the maximum is 8 bpp, which encodes up to 256 colours
# (at the expense of consuming a whole byte).