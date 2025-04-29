require 'minitest/autorun'
require_relative '../src/utils/file'
require_relative '../src/snes/console'

module MundauSnesTest
    # Snes tests
    Dir.glob(File.join(__dir__, 'snes/**/*_test.rb')).sort.each { |file| require_relative file }
end