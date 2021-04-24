require 'test'

class DiskTest < Test
  
  RESCUE_DISKS = 'test/data/rescue-disks.txt'
  HPE_DISKS = 'test/data/hpe-disks.txt'




  def test_rescue_disks
    rescue_disks  do 
      puts Disk.to_string_list     
    end
  end



  def rescue_disks(&block)
    with_disks RESCUE_DISKS, block
  end

  def hpe_disks(&block)
    with_disks HPE_DISKS, block
  end


  def with_disks(disks_file, block)
    block
    Disk.stub :get_hwinfo, IO.read(disks_file) do 
      with_rotation block
    end
  end


  def with_rotation(block)
    stubbed_disks = Disk.all.map {|disk|
      disk.stub :rotation, /^ata/ =~ disk.id do
      disk
    end
    }
    Disk.stub :all, stubbed_disks do
      yield block
    end
  end

end
