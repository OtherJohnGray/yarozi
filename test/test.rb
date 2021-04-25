require 'minitest/autorun'
require 'mocha/minitest'
require 'bundler'
Bundler.require


loader = Zeitwerk::Loader.new
loader.push_dir('./lib')
loader.setup # ready!

Logging.setup

Minitest.parallel_executor = Minitest::ForkExecutor.new

class Test < Minitest::Test

  RESCUE_DISKS = 'test/data/rescue-disks.txt'
  HPE_DISKS = 'test/data/hpe-disks.txt'
  USB_DISKS = 'test/data/usb-disks.txt'

  def rescue_disks(&block)
    with_disks RESCUE_DISKS, &block
  end

  def hpe_disks(&block)
    with_disks HPE_DISKS, &block
  end


  def usb_disks(&block)
    with_disks USB_DISKS, &block
  end


  def with_disks(disks_file)
    # Disk.any_instance.stubs(:rotation).returns Proc.new {puts "id is #{id}"}
    Disk.alias_method :old_rotation, :rotation
    Disk.define_method :rotation, Proc.new { /^ata-ST/ =~ id }
    Disk.expects(:get_hwinfo).returns IO.read(disks_file)
    Disk.reload
    yield
    Disk.undef_method :rotation
    Disk.alias_method :rotation, :old_rotation
    Disk.undef_method :old_rotation
  end


end



