# ROM Data is available in 32 KB chunks with 128 banks to choose from [25].
# SRAM, on the other side, fits in two banks, but it’s been made accessible across 15 banks where ROM data can also be found.
#
# This will mean the game/program may need to perform significant bank switching during execution.
# On the other side, half of the banks are mapped to part of WRAM as well
# (meaning ROM, SRAM and WRAM can be accessed without switching banks).