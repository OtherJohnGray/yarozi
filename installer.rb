# load gems
require 'bundler'
Bundler.require

# set autoload for lib dir
loader = Zeitwerk::Loader.new
loader.push_dir('./lib')
loader.setup # ready!

# start the root installer
Task::RootInstaller.new.run