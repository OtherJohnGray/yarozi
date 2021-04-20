require 'test'

class DiskTest < Test
  
  def test_disks_exist
    assert Disk.all.class == Array
  end

end
