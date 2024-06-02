#     Mode 0: 4 layers with 4 colours each.
#         The colour palette is particularly bland since this mode is the only one allowing the largest number of layers.
#     Mode 1: 2 layers with 16 colours each + 1 layer with 4 colours.
#         One layer can be split into foreground and background.
#         This is the most common mode used.
#     Mode 2: 2 layers with 16 colours each.
#         This mode has an extra effect: Layers can have each of their columns scrolled independently (similarly to Game Boy effects but vertically scrolled).
#     Mode 3: 1 Background layer with 128 colours + 1 Background with 16 colours.
#         Colours can be set as RGB values instead of using CGRAM references.
#     Mode 4: Mode 2 and 3 combined (Column scroll + RGB colour mapping).
#         The first layer has 128 colours and the second one only has 4.
#     Mode 5: 1 layer with 16 colours + 1 layer with 4 colours.
#         The selected area will have an outstanding resolution of 512 x 224 pixels which will be squashed horizontally to fit on the screen (the output frame is still 256 x 224 pixels!). This comes at the cost of rendering 16 x 8 pixels tiles as 8 x 8 ones, and 16 x 16 pixels tiles as 8 x 16 ones.
#         Furthermore, the vertical resolution can be extended as well by activating interlacing (reaching 512 x 448 pixels, which is now proportional to the output dimension). In exchange, the same squashing effect will affect tiles but now vertically too. This is useful for cases when the screen has to display extra amounts of information (i.e. during multiplayer/split-screen).
#     Mode 6: Combination of Mode 2 and 5 (high resolution + column scrolling), but only one layer with 32 colours is allowed.
#   Mode 7: et another background mode, but this time, with a completely different way of working. While it can only render a single 8 bpp background layer, it provides the exclusive ability to apply the following affine transformations on that plane