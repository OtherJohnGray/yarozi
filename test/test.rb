require 'minitest/autorun'
require 'minitest/stub_any_instance'
require 'bundler'
Bundler.require

loader = Zeitwerk::Loader.new
loader.push_dir('./lib')
loader.setup # ready!

Logging.setup

Minitest.parallel_executor = Minitest::ForkExecutor.new

class Test < Minitest::Test

# Disk mocking

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
    Disk.stub_any_instance(:rotation, Proc.new{ /^ata-ST/ =~ id } ) do
      Disk.stub :get_hwinfo, IO.read(disks_file) do
        Disk.reload
        yield
      end
    end
  end

# Screen mocking

  def with_dialog(type, retval = Proc.new{|*args| args} )
    MRDialog.stub_any_instance(type, retval ) do
      yield
    end
  end

  def with_screen(rows, cols)
    Question::Dialog.stub :rows, rows do
      Question::Dialog.stub :cols, cols do
        yield
      end
    end
  end

  def compare_to_saved(newval)
    filename = "test/data" + caller_locations[0].path[/test(.+?)\.rb/, 1] + "." + caller_locations[0].base_label + ".txt"
    IO.write filename, newval unless File.exist? filename
    assert_equal IO.read(filename), newval
  end

  def assert_quit(code)
    result = nil
    Question.stub_any_instance :quit, Proc.new{|errcode| result = errcode } do
      yield
    end
    assert_equal code, result
  end

  def assert_not_quit
    result = nil
    Question.stub_any_instance :quit, Proc.new{|errcode| result = errcode } do
      yield
    end
    assert_nil result
  end

end



