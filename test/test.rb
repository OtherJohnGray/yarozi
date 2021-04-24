require 'minitest/autorun'
require 'mocha/minitest'
require 'bundler'
Bundler.require


loader = Zeitwerk::Loader.new
loader.push_dir('./lib')
loader.setup # ready!

Logging.setup

class Test < Minitest::Test

end



