# Stores audio data and programs. The main CPU is responsible for filling this up.
# 64 KB SRAM (ARAM?) Static random-access memory - https://en.wikipedia.org/wiki/Static_random-access_memory
#
# If ‘Delay’ is activated, some space will be allocated for feedback data (this is actually very dangerous, since if not used carefully, it can override existing data!).
#
# hen the console is turned on, the SPC700 boots a 64-byte internal ROM that sets it up to receive commands from the main CPU [18]. After that, it stays idle
#
# For the S-SMP to start doing useful work, it needs to load a type of program referred to as Sound Driver. The latter instructs the chip on how to manipulate the raw audio data that the main CPU sends to PSRAM and also how to command the S-DSP.