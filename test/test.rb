require 'minitest/autorun'
require 'minitest/stub_any_instance'
require 'bundler'
require 'forwardable'
require 'm_r_dialog'
Bundler.require

loader = Zeitwerk::Loader.new
loader.push_dir('./lib')
loader.setup # ready!

Logging.setup

Minitest.parallel_executor = Minitest::ForkExecutor.new

class Test < Minitest::Test

  DISK_SETS = %w(hdd mixed usb largesector)

  # Disk mocking
  DISK_SETS.each do |set|
    define_method("#{set}_disks".to_sym) do |&block|
      Disk.stub_any_instance(:rotation, Proc.new{ /^ata-ST/ =~ id } ) do
        Disk.stub :get_hwinfo, IO.read("test/data/#{set}-disks.txt") do
          Disk.reload
          block.call set
        end
      end
    end
  end

  def with_disk_sets(&block)
    DISK_SETS.each do |set|
      method("#{set}_disks".to_sym).call &block
    end
  end

# Screen mocking

  def with_dialog(type, retval = Proc.new{|*args| args} )
    Dialog.stub_any_instance(type, retval ) do
      yield
    end
  end

  def with_screen(rows, cols)
    Dialog.stub :rows, rows do
      Dialog.stub :cols, cols do
        yield
      end
    end
  end

  def fetch_or_save(newval, qualifier="")
    qualifier = "_with_#{qualifier}_disks" if DISK_SETS.include? qualifier
    filename = "test/data" + caller_locations[0].path[/test(.+?)\.rb/, 1] + "." + caller_locations[0].base_label + qualifier + ".txt"
    if File.exist? filename
      IO.read(filename)
    else
      IO.write filename, newval
      newval
    end
  end

  def quit_code
    code = nil
    QuestionList.stub_any_instance :quit, Proc.new{|errcode| code = errcode } do
      Question.stub_any_instance :quit, Proc.new{ code = 1 } do
        yield
      end
    end
    code
  end


end



