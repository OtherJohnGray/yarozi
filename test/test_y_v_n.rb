require 'test'

class TestYVN < Test

  def test_simple_mirror
    YVN.new('M:20G[1,2]').tap do |y|
      assert y.valid?
      assert y.errors.empty?
      assert_equal 1, y.vdevs.size
      assert_equal [1,2], y.vdevs.first.disks
    end
  end

  # def test_striped_mirror
  #   mixed_disks do
  #     assert YVN.new('M:20G[1,2] M:20G[3,4]').valid_zpool?
  #   end
  # end

  # def test_
  #   mixed_disks do
  #     assert YVN.new('Z1:200G[1-6]').valid_zpool?
  #     assert YVN.new('Z1:200G[1,2]').valid_zpool?
  #   end
  # end

  # def test_too_many
  #   hdd_disks do
  #     yvn = YVN.new('M:20G[1,2] M:20G[3,4]')
  #     assert !yvn.valid_zpool?
  #     assert_equal fetch_or_save(yvn.zpool_errors), yvn.zpool_errors.to_s
  #   end
  # end


end
  