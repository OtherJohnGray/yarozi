require 'test'

class TestYVN < Test

  def test_simple_mirror
    hdd_disks do
      assert YVN.new('M:20G[1,2]').valid_zpool?
    end
  end

  def test_striped_mirror
    mixed_disks do
      assert YVN.new('M:20G[1,2] M:20G[3,4]').valid_zpool?
    end
  end

  def test_too_many
    hdd_disks do
      yvn = YVN.new('M:20G[1,2] M:20G[3,4]')
      assert !yvn.valid_zpool?
p yvn.zpool_errors       
    end
  end


end
  