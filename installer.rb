# load gems
require 'bundler'
Bundler.require

# set autoload for lib dir
loader = Zeitwerk::Loader.new
loader.push_dir('./lib')
loader.setup # ready!

# Start logging
Logging.setup


# start the root installer
RootInstaller::Installer.new.start