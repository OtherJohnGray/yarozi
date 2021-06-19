require 'test'

class TestLayout < Test

  def test_valid
    hdd_disks do
      Layout.new.tap do |layout|
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('M', '4G', [1,2])}
        layout.root_pool = ZPool.new.tap{|b| b << VDEV.new('M', '500G', [1,2])}
        layout.legacy_boot = true
        assert layout.valid?
      end
    end
  end

  def test_invalid_disk_number
    hdd_disks do
      Layout.new.tap do |layout|
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('M', '4G', [1,2,3])}
        refute layout.valid?
        assert_equal 1, layout.errors.size
        assert_equal "boot pool vdev 1 specifies a disk number 3, but there are only 2 disks in the system", layout.errors.first
      end
    end
  end

  def test_invalid_size
    hdd_disks do
      # oversized boot
      Layout.new.tap do |layout|
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('M', '1.5T', [1,2])}
        assert layout.valid?
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('M', '4T', [1,2])}
        refute layout.valid?
        assert_equal 2, layout.errors.size
        assert_equal "The total space allocated to disk 1 exceeds it's capacity", layout.errors.first
        assert_equal "The total space allocated to disk 2 exceeds it's capacity", layout.errors.last
      end
      # oversized root
      Layout.new.tap do |layout|
        layout.root_pool = ZPool.new.tap{|b| b << VDEV.new('M', '1.5T', [1,2])}
        assert layout.valid?
        layout.root_pool = ZPool.new.tap{|b| b << VDEV.new('M', '4T', [1,2])}
        refute layout.valid?
        assert_equal 2, layout.errors.size
        assert_equal "The total space allocated to disk 1 exceeds it's capacity", layout.errors.first
        assert_equal "The total space allocated to disk 2 exceeds it's capacity", layout.errors.last
      end
      # oversized swap
      Layout.new.tap do |layout|
        layout.swap = ZPool.new.tap{|b| b << VDEV.new('M', '1.5T', [1,2])}
        assert layout.valid?
        layout.swap = ZPool.new.tap{|b| b << VDEV.new('M', '4T', [1,2])}
        refute layout.valid?
        assert_equal 2, layout.errors.size
        assert_equal "The total space allocated to disk 1 exceeds it's capacity", layout.errors.first
        assert_equal "The total space allocated to disk 2 exceeds it's capacity", layout.errors.last
      end
      # combined oversized
      Layout.new.tap do |layout|
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('M', '0.5T', [1,2])}
        layout.root_pool = ZPool.new.tap{|b| b << VDEV.new('M', '0.5T', [1,2])}
        layout.swap = ZPool.new.tap{|b| b << VDEV.new('M', '0.5T', [1,2])}
        assert layout.valid?
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('M', '1T', [1,2])}
        layout.root_pool = ZPool.new.tap{|b| b << VDEV.new('M', '1T', [1,2])}
        layout.swap = ZPool.new.tap{|b| b << VDEV.new('M', '1T', [1,2])}
        refute layout.valid?
        assert_equal 2, layout.errors.size
        assert_equal "The total space allocated to disk 1 exceeds it's capacity", layout.errors.first
        assert_equal "The total space allocated to disk 2 exceeds it's capacity", layout.errors.last
      end
      # mbr exceeds 
      Layout.new.tap do |layout|
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('M', "#{Disk.all.first.capacity_bytes}B", [1,2])}
        assert layout.valid?
        layout.legacy_boot = true
        refute layout.valid?
        assert_equal 2, layout.errors.size
        assert_equal "The total space allocated to disk 1 exceeds it's capacity", layout.errors.first
        assert_equal "The total space allocated to disk 2 exceeds it's capacity", layout.errors.last
      end
      # efi exceeds 
      Layout.new.tap do |layout|
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('M', "#{Disk.all.first.capacity_bytes - 2**20}B", [1,2])}
        layout.legacy_boot = true
        assert layout.valid?
        layout.efi_partition = true
        refute layout.valid?
        assert_equal 2, layout.errors.size
        assert_equal "The total space allocated to disk 1 exceeds it's capacity", layout.errors.first
        assert_equal "The total space allocated to disk 2 exceeds it's capacity", layout.errors.last
      end
    end
  end

end