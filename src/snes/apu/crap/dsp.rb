# Plays ADPCM samples across eight different channels, they are mixed and sent through the audio output.
# 16-bit
# The DSP is capable of manipulating samples with 16-bit resolution and a sampling rate of 32 kHz, it also provides
#
#     Stereo Panning: Distributes our channels to provide stereo sound.
#     ADSR envelope control: Sets how the volume changes at different times.
#     Delay: Simulates echo effects. It also includes a frequency filter to cut out some frequencies during the feedback. Don’t confuse this with Reverb!
#     Noise generator: Generates pseudo-random waveforms that sound like white static.
#     Pitch modulation: Allows some channels to distort others. Similar to FM synthesis (used by its competitor).