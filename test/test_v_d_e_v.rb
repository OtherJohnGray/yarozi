require 'test'

class TestVDEV < Test

  def test_bytes
    assert_equal 20, VDEV.new('S', '20B', [1]).partition_bytes
    assert_equal 20 * 2**10, VDEV.new('S', '20K', [1]).partition_bytes
    assert_equal 20 * 2**20, VDEV.new('S', '20M', [1]).partition_bytes
    assert_equal 20 * 2**30, VDEV.new('S', '20G', [1]).partition_bytes
    assert_equal 20 * 2**40, VDEV.new('S', '20T', [1]).partition_bytes
    assert_equal (0.5 * 2**40).to_i, VDEV.new('S', '0.5T', [1]).partition_bytes
  end

end