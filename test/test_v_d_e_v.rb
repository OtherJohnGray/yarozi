require 'test'

class TestVDEV < Test

  def test_bytes
    assert_equal 20, VDEV.new('S', '20B', [1]).partition_bytes
    assert_equal 20 * 2**10, VDEV.new('S', '20K', [1]).partition_bytes
    assert_equal 20 * 2**20, VDEV.new('S', '20M', [1]).partition_bytes
    assert_equal 20 * 2**30, VDEV.new('S', '20G', [1]).partition_bytes
    assert_equal 20 * 2**40, VDEV.new('S', '20T', [1]).partition_bytes
    assert_equal (0.5 * 2**40).to_i, VDEV.new('S', '0.5T', [1]).partition_bytes
    assert_equal '*', VDEV.new('S', '*', [1]).partition_bytes
  end

  def test_errors
    assert VDEV.new('S', '20K', [1]).valid?
    assert VDEV.new('M', '20K', [1,2]).valid?
    assert VDEV.new('Z1', '20K', [1,2]).valid?
    assert VDEV.new('Z2', '20K', [1,2,3]).valid?
    assert VDEV.new('Z3', '20K', [1,2,3,4]).valid?
    assert VDEV.new('R1', '20K', [1,2]).valid?
    assert VDEV.new('R5', '20K', [1,2]).valid?
    assert VDEV.new('R6', '20K', [1,2,3]).valid?
    VDEV.new(nil, '20K', [1]).tap do |vdev|
      refute vdev.valid?
      assert_equal 1, vdev.errors.size
      assert_equal "type must be one of S, M, Z1, Z2, Z3, R1, R5 or R6", vdev.errors.first
    end
    VDEV.new('A', '20K', [1]).tap do |vdev|
      refute vdev.valid?
      assert_equal 1, vdev.errors.size
      assert_equal "type must be one of S, M, Z1, Z2, Z3, R1, R5 or R6", vdev.errors.first
    end
    VDEV.new('S', nil, [1]).tap do |vdev|
      refute vdev.valid?
      assert_equal 1, vdev.errors.size
      assert_equal "partition size must be either a number followed by T, G, M, K or B, or else a *", vdev.errors.first
    end
    VDEV.new('S', '20', [1]).tap do |vdev|
      refute vdev.valid?
      assert_equal 1, vdev.errors.size
      assert_equal "partition size must be either a number followed by T, G, M, K or B, or else a *", vdev.errors.first
    end
    VDEV.new('S', '20G', nil).tap do |vdev|
      refute vdev.valid?
      assert_equal 1, vdev.errors.size
      assert_equal "disks must be an array of integers", vdev.errors.first
    end
    VDEV.new('S', '20G', 5).tap do |vdev|
      refute vdev.valid?
      assert_equal 1, vdev.errors.size
      assert_equal "disks must be an array of integers", vdev.errors.first
    end
    VDEV.new('S', '20G', ['one']).tap do |vdev|
      refute vdev.valid?
      assert_equal 1, vdev.errors.size
      assert_equal "disks must be an array of integers", vdev.errors.first
    end
    VDEV.new('S', '20G', []).tap do |vdev|
      refute vdev.valid?
      assert_equal 1, vdev.errors.size
      assert_equal "disks must be an array of integers", vdev.errors.first
    end
    VDEV.new('S', '20G', [1,2]).tap do |vdev|
      refute vdev.valid?
      assert_equal 1, vdev.errors.size
      assert_equal "'single' device must have exactly 1 disk", vdev.errors.first
    end
    VDEV.new('M', '20G', [1]).tap do |vdev|
      refute vdev.valid?
      assert_equal 1, vdev.errors.size
      assert_equal "mirror vdev must have at least 2 disks", vdev.errors.first
    end
    VDEV.new('Z1', '20G', [1]).tap do |vdev|
      refute vdev.valid?
      assert_equal 1, vdev.errors.size
      assert_equal "RAIDZ1 vdev must have at least 2 disks", vdev.errors.first
    end
    VDEV.new('Z2', '20G', [1,2]).tap do |vdev|
      refute vdev.valid?
      assert_equal 1, vdev.errors.size
      assert_equal "RAIDZ2 vdev must have at least 3 disks", vdev.errors.first
    end
    VDEV.new('Z3', '20G', [1,2,3]).tap do |vdev|
      refute vdev.valid?
      assert_equal 1, vdev.errors.size
      assert_equal "RAIDZ3 vdev must have at least 4 disks", vdev.errors.first
    end
    VDEV.new('R1', '20G', [1]).tap do |vdev|
      refute vdev.valid?
      assert_equal 1, vdev.errors.size
      assert_equal "RAID1 volume must have at least 2 disks", vdev.errors.first
    end
    VDEV.new('R5', '20G', [1]).tap do |vdev|
      refute vdev.valid?
      assert_equal 1, vdev.errors.size
      assert_equal "RAID5 volume must have at least 2 disks", vdev.errors.first
    end
    VDEV.new('R6', '20G', [1,2]).tap do |vdev|
      refute vdev.valid?
      assert_equal 1, vdev.errors.size
      assert_equal "RAID6 volume must have at least 3 disks", vdev.errors.first
    end
  end

end