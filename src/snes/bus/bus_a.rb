'''
+----------------------+                     +--------------------+
|    Game Cartridge    |                     |                    |
|                      |                     |    WRAM            |
|                      |                     |                    |
|     +------------+   |         Bus A       |                    |
|     |            |   |               +-----|                    |
|     |   Mask     |   |               |     +--------------------+
|     |   ROM      |   |               |
|     |            |---|---------------|
|     |            |   |               |
|     +------------+   |               |
|                      |           +----------------+
|                      |           |                |
|                      |           |  Ricoh 5A22    |
+----------------------+           |                |
                                   |                |
                                   +----------------+
'''

# 24-bit ‘A Bus’ controlled by the CPU: Connects the cartridge, CPU and WRAM.
# Access up to 16 MB worth of data
class BusA

end