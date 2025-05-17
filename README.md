Ruby Super Nintendo Emulator

Change ruby version on RubyMine:
File -> Settings -> Ruby SDK
Add -> Remote Interpreter
Put this path /home/alisson/.rbenv/bin/rbenv

# Disclaimer Postmortem
Best I could do was running the emulator at 650 ns per instruction which is far less what the Snes requires (120 ns) 

# Run emulator
ruby src/main.rb

# Run emulator no debug
ruby src/main.rb nd

# Run tests
ruby tests/run_tests.rb
