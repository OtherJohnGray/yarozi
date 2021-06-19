require 'test'

class TestYVN < Test

  def test_single_disk
    YVN.new('S:20G[1]').tap do |y|
      assert y.valid?
      assert y.errors.empty?
      assert_equal 1, y.zpool.size
      assert_equal [1], y.zpool.first.disks
      assert_equal 'S', y.zpool.first.type
      assert_equal '20G', y.zpool.first.partition_size
    end
  end

  def test_simple_mirror
    YVN.new('M:0.5T[1,2]').tap do |y|
      assert y.valid?
      assert y.errors.empty?
      assert_equal 1, y.zpool.size
      assert_equal [1,2], y.zpool.first.disks
      assert_equal 'M', y.zpool.first.type
      assert_equal '0.5T', y.zpool.first.partition_size
    end
  end

  def test_simple_raidz
    YVN.new('Z1:20G[1-5]').tap do |y|
      assert y.valid?
      assert y.errors.empty?
      assert_equal 1, y.zpool.size
      assert_equal [1,2,3,4,5], y.zpool.first.disks
      assert_equal 'Z1', y.zpool.first.type
      assert_equal '20G', y.zpool.first.partition_size
    end
  end

  def test_mixed_disks
    YVN.new('Z1:100G[1-3,6,11-14] Z1:100G[30-36,42]').tap do |y|
      assert y.valid?
      assert y.errors.empty?
      assert_equal 2, y.zpool.size
      assert_equal [1,2,3,6,11,12,13,14], y.zpool.first.disks
      assert_equal 'Z1', y.zpool.first.type
      assert_equal '100G', y.zpool.first.partition_size
      assert_equal [30,31,32,33,34,35,36,42], y.zpool.last.disks
      assert_equal 'Z1', y.zpool.last.type
      assert_equal '100G', y.zpool.last.partition_size
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
    assert_equal '20T', YVN.new('M:20T[1,2]').zpool.first.partition_size
    assert_equal '20G', YVN.new('M:20G[1,2]').zpool.first.partition_size
    assert_equal '20M', YVN.new('M:20M[1,2]').zpool.first.partition_size
    assert_equal '20K', YVN.new('M:20K[1,2]').zpool.first.partition_size
    assert_equal '20B', YVN.new('M:20B[1,2]').zpool.first.partition_size
    assert_equal '*', YVN.new('M:*[1,2]').zpool.first.partition_size
  end

  def test_errors
    msg = [
      "must have exactly one disk if type is S",
      "must start with type identifier of S, M, Z1, Z2, Z3, R1, R5, or R6",
      "must have : immediately following the type identifier",
      "must include partition size (either * or numbers followed by one of T,G,M,K or B ) immediately following the type and : characters",
      "must contain a list of disk numbers and/or dashed ranges, comma separated and inside square brackets"
    ]
    assert_equal msg[0], YVN.new('S:20G[1,2]' ).errors.first
    assert_equal msg[0], YVN.new('S:20G[1,2]' ).segments.first.errors.first
    assert_equal msg[1], YVN.new('A:20G[1,2]' ).errors.first
    assert_equal msg[2], YVN.new('M-20G[1,2]' ).errors.first
    assert_equal msg[3], YVN.new('M:G100[1,2]').errors.first
    assert_equal msg[3], YVN.new('M:20[1,2]'  ).errors.first
    assert_equal msg[4], YVN.new('M:20G,1,2'  ).errors.first
  end

end
  