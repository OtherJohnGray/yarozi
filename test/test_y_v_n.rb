require 'test'

class TestYVN < Test

  def test_single_disk
    YVN.new('S:20G[1]').tap do |y|
      assert y.valid?
      assert y.errors.empty?
      assert_equal 1, y.zpool.size
      assert_equal [1], y.zpool.first.disks
      assert_equal 'S', y.zpool.first.type
      assert_equal 20, y.zpool.first.size
      assert_equal 'G', y.zpool.first.units
    end
  end

  def test_simple_mirror
    YVN.new('M:20G[1,2]').tap do |y|
      assert y.valid?
      assert y.errors.empty?
      assert_equal 1, y.zpool.size
      assert_equal [1,2], y.zpool.first.disks
      assert_equal 'M', y.zpool.first.type
      assert_equal 20, y.zpool.first.size
      assert_equal 'G', y.zpool.first.units
    end
  end

  def test_simple_raidz
    YVN.new('Z1:20G[1-5]').tap do |y|
      assert y.valid?
      assert y.errors.empty?
      assert_equal 1, y.zpool.size
      assert_equal [1,2,3,4,5], y.zpool.first.disks
      assert_equal 'Z1', y.zpool.first.type
      assert_equal 20, y.zpool.first.size
      assert_equal 'G', y.zpool.first.units
    end
  end

  def test_mixed_disks
    YVN.new('Z1:100G[1-3,6,11-14] Z1:100G[30-36,42]').tap do |y|
      assert y.valid?
      assert y.errors.empty?
      assert_equal 2, y.zpool.size
      assert_equal [1,2,3,6,11,12,13,14], y.zpool.first.disks
      assert_equal 'Z1', y.zpool.first.type
      assert_equal 100, y.zpool.first.size
      assert_equal 'G', y.zpool.first.units
      assert_equal [30,31,32,33,34,35,36,42], y.zpool.last.disks
      assert_equal 'Z1', y.zpool.last.type
      assert_equal 100, y.zpool.last.size
      assert_equal 'G', y.zpool.last.units
    end
  end

  def test_types
    assert_equal 'S', YVN.new('S:20G[1]').zpool.first.type
    assert_equal 'M', YVN.new('M:20G[1,2]').zpool.first.type
    assert_equal 'Z1', YVN.new('Z1:20G[1-5]').zpool.first.type
    assert_equal 'Z2', YVN.new('Z2:20G[1-5]').zpool.first.type
    assert_equal 'Z3', YVN.new('Z3:20G[1-5]').zpool.first.type
    assert_equal 'R1', YVN.new('R1:20G[1-5]').zpool.first.type
    assert_equal 'R5', YVN.new('R5:20G[1-5]').zpool.first.type
    assert_equal 'R6', YVN.new('R6:20G[1-5]').zpool.first.type
  end

  def test_units
    assert_equal 'T', YVN.new('M:20T[1,2]').zpool.first.units
    assert_equal 'G', YVN.new('M:20G[1,2]').zpool.first.units
    assert_equal 'M', YVN.new('M:20M[1,2]').zpool.first.units
  end

  def test_errors
    msg = [
      "must have exactly one disk if type is S",
      "must start with type identifier of S, M, Z1, Z2, Z3, R1, R5, or R6",
      "must have : as the 2nd or 3rd character",
      "must include partition size immediately following the type and : characters",
      "must include size units of M, G, or T immediately following the partition size value",
      "must contain a list of disk numbers and/or dashed ranges, comma separated and inside square brackets"
    ]
    assert_equal msg[0], YVN.new('S:20G[1,2]' ).errors.first
    assert_equal msg[0], YVN.new('S:20G[1,2]' ).segments.first.errors.first
    assert_equal msg[1], YVN.new('A:20G[1,2]' ).errors.first
    assert_equal msg[2], YVN.new('M-20G[1,2]' ).errors.first
    assert_equal msg[3], YVN.new('M:G100[1,2]').errors.first
    assert_equal msg[4], YVN.new('M:20[1,2]'  ).errors.first
    assert_equal msg[5], YVN.new('M:20G,1,2'  ).errors.first
  end

end
  