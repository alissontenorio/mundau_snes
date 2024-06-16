# Horizontal DMA (HDMA) performs a small transfer after each horizontal scan
# (while the CRT beam is preparing to draw the next row).
# This avoids interrupting the CPU for long intervals but transfers are limited to 4 bytes per scanline