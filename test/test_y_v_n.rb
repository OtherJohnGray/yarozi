require 'test'

class TestYVN < Test

  # def test_simple_mirror
  #   hdd_disks do
  #     assert YVN.new('M:20G[1,2]').valid_zpool?
  #   end
  # end

  # def test_striped_mirror
  #   mixed_disks do
  #     assert YVN.new('M:20G[1,2] M:20G[3,4]').valid_zpool?
  #   end
  # end

  def test_z
    mixed_disks do
      assert YVN.new('Z1:200G[1-6]').valid_zpool?
      assert YVN.new('Z1:200G[1,2]').valid_zpool?
    end
  end

  # def test_too_many
  #   hdd_disks do
  #     yvn = YVN.new('M:20G[1,2] M:20G[3,4]')
  #     assert !yvn.valid_zpool?
  #     assert_equal fetch_or_save(yvn.zpool_errors), yvn.zpool_errors.to_s
  #   end
  # end


end
  