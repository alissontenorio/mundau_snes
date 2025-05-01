Mundau Super Nintendo Emulator

Change ruby version on RubyMine:
File -> Settings -> Ruby SDK
Add -> Remote Interpreter
Put this path /home/alisson/.rbenv/bin/rbenv

# Run emulator
ruby src/main.rb

# Run emulator no debug
ruby src/main.rb nd

# Run tests
ruby tests/run_tests.rb
