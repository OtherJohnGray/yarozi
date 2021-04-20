require 'minitest/autorun'
require 'bundler'
Bundler.require
loader = Zeitwerk::Loader.new
loader.push_dir('./lib')
loader.setup # ready!

Logging.start

class Test < Minitest::Test

end



