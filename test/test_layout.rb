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
        layout.swap = ZPool.new.tap{|b| b << VDEV.new('R1', '1.5T', [1,2])}
        assert layout.valid?
        layout.swap = ZPool.new.tap{|b| b << VDEV.new('R1', '4T', [1,2])}
        refute layout.valid?
        assert_equal 2, layout.errors.size
        assert_equal "The total space allocated to disk 1 exceeds it's capacity", layout.errors.first
        assert_equal "The total space allocated to disk 2 exceeds it's capacity", layout.errors.last
      end
      # combined oversized
      Layout.new.tap do |layout|
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('M', '0.5T', [1,2])}
        layout.root_pool = ZPool.new.tap{|b| b << VDEV.new('M', '0.5T', [1,2])}
        layout.swap = ZPool.new.tap{|b| b << VDEV.new('R1', '0.5T', [1,2])}
        assert layout.valid?
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('M', '1T', [1,2])}
        layout.root_pool = ZPool.new.tap{|b| b << VDEV.new('M', '1T', [1,2])}
        layout.swap = ZPool.new.tap{|b| b << VDEV.new('R1', '1T', [1,2])}
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

  def test_wildcard
    hdd_disks do
      # valid boot
      Layout.new.tap do |layout|
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('M', '*', [1,2])}
        layout.root_pool = ZPool.new.tap{|b| b << VDEV.new('M', '0.8T', [1,2])}
        layout.swap = ZPool.new.tap{|b| b << VDEV.new('R1', '0.8T', [1,2])}
        assert layout.valid?
      end
      # valid root
      Layout.new.tap do |layout|
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('M', '0.8T', [1,2])}
        layout.root_pool = ZPool.new.tap{|b| b << VDEV.new('M', '*', [1,2])}
        layout.swap = ZPool.new.tap{|b| b << VDEV.new('R1', '0.8T', [1,2])}
        assert layout.valid?
      end
      # valid swap
      Layout.new.tap do |layout|
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('M', '0.8T', [1,2])}
        layout.root_pool = ZPool.new.tap{|b| b << VDEV.new('M', '0.8T', [1,2])}
        layout.swap = ZPool.new.tap{|b| b << VDEV.new('R1', '*', [1,2])}
        assert layout.valid?
      end
      # invalid
      Layout.new.tap do |layout|
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('M', '*', [1,2])}
        layout.root_pool = ZPool.new.tap{|b| b << VDEV.new('M', '*', [1,2,1,1])}
        layout.swap = ZPool.new.tap{|b| b << VDEV.new('R1', '*', [1,2])}
        refute layout.valid?
        assert_equal "More than one size wildcard (*) specified for disk 1: 1 from boot vdev 1, 3 from root vdev 1, and 1 from swap device 1", layout.errors[0]
        assert_equal "More than one size wildcard (*) specified for disk 2: 1 from boot vdev 1, 1 from root vdev 1, and 1 from swap device 1", layout.errors[1]
      end
    end
  end

  def test_type
    usb_disks do
      # boot type
      Layout.new.tap do |layout|
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('S', '10G', [1])}
        assert layout.valid?
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('M', '10G', [1,2])}
        assert layout.valid?
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('Z1', '1T', [3,4,5,6])}
        assert layout.valid?
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('Z2', '1T', [3,4,5,6])}
        assert layout.valid?
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('Z3', '1T', [3,4,5,6])}
        assert layout.valid?
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('R1', '1T', [3,4,5,6])}
        refute layout.valid?
        assert_equal 1, layout.errors.size
        assert_equal "boot vdev 1 has type R1 which is not valid for a boot pool", layout.errors[0]
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('R5', '1T', [3,4,5,6])}
        refute layout.valid?
        assert_equal 1, layout.errors.size
        assert_equal "boot vdev 1 has type R5 which is not valid for a boot pool", layout.errors[0]
        layout.boot_pool = ZPool.new.tap{|b| b << VDEV.new('R6', '1T', [3,4,5,6])}
        refute layout.valid?
        assert_equal 1, layout.errors.size
        assert_equal "boot vdev 1 has type R6 which is not valid for a boot pool", layout.errors[0]
      end
      # root type
      Layout.new.tap do |layout|
        layout.root_pool = ZPool.new.tap{|b| b << VDEV.new('S', '10G', [1])}
        assert layout.valid?
        layout.root_pool = ZPool.new.tap{|b| b << VDEV.new('M', '10G', [1,2])}
        assert layout.valid?
        layout.root_pool = ZPool.new.tap{|b| b << VDEV.new('Z1', '1T', [3,4,5,6])}
        assert layout.valid?
        layout.root_pool = ZPool.new.tap{|b| b << VDEV.new('Z2', '1T', [3,4,5,6])}
        assert layout.valid?
        layout.root_pool = ZPool.new.tap{|b| b << VDEV.new('Z3', '1T', [3,4,5,6])}
        assert layout.valid?
        layout.root_pool = ZPool.new.tap{|b| b << VDEV.new('R1', '1T', [3,4,5,6])}
        refute layout.valid?
        assert_equal 1, layout.errors.size
        assert_equal "root vdev 1 has type R1 which is not valid for a root pool", layout.errors[0]
        layout.root_pool = ZPool.new.tap{|b| b << VDEV.new('R5', '1T', [3,4,5,6])}
        refute layout.valid?
        assert_equal 1, layout.errors.size
        assert_equal "root vdev 1 has type R5 which is not valid for a root pool", layout.errors[0]
        layout.root_pool = ZPool.new.tap{|b| b << VDEV.new('R6', '1T', [3,4,5,6])}
        refute layout.valid?
        assert_equal 1, layout.errors.size
        assert_equal "root vdev 1 has type R6 which is not valid for a root pool", layout.errors[0]
      end
      # swap type
      Layout.new.tap do |layout|
        layout.swap = ZPool.new.tap{|b| b << VDEV.new('S', '10G', [1])}
        assert layout.valid?
        layout.swap = ZPool.new.tap{|b| b << VDEV.new('R1', '10G', [1,2])}
        assert layout.valid?
        layout.swap = ZPool.new.tap{|b| b << VDEV.new('R5', '1T', [3,4,5,6])}
        assert layout.valid?
        layout.swap = ZPool.new.tap{|b| b << VDEV.new('R6', '1T', [3,4,5,6])}
        assert layout.valid?
        layout.swap = ZPool.new.tap{|b| b << VDEV.new('M', '1T', [3,4])}
        refute layout.valid?
        assert_equal 1, layout.errors.size
        assert_equal "swap device 1 has type M which is not valid for swap", layout.errors[0]
        layout.swap = ZPool.new.tap{|b| b << VDEV.new('Z1', '1T', [3,4,5,6])}
        refute layout.valid?
        assert_equal 1, layout.errors.size
        assert_equal "swap device 1 has type Z1 which is not valid for swap", layout.errors[0]
        layout.swap = ZPool.new.tap{|b| b << VDEV.new('Z2', '1T', [3,4,5,6])}
        refute layout.valid?
        assert_equal 1, layout.errors.size
        assert_equal "swap device 1 has type Z2 which is not valid for swap", layout.errors[0]
        layout.swap = ZPool.new.tap{|b| b << VDEV.new('Z3', '0.5T', [3,4,5,6]); b << VDEV.new('Z3', '0.5T', [3,4,5,6])}
        refute layout.valid?
        assert_equal 2, layout.errors.size
        assert_equal "swap device 1 has type Z3 which is not valid for swap", layout.errors[0]
        assert_equal "swap device 2 has type Z3 which is not valid for swap", layout.errors[1]
      end      
    end
  end
end