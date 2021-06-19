# This class owns the responsibility of mapping a YVN vdev map to actual disk partitions
class Layout < Struct.new :boot_pool, :root_pool, :legacy_boot, :efi_partition

  MBR_SIZE = 2**20
  EFI_SIZE = 2**29

  def valid?
    errors.empty?
  end

  def errors
    Array.new.tap do |errors|
      Hash.new.tap do |disks|
        boot_pool && boot_pool.each_with_index do |vdev, index|
          vdev.disks.each do |vdev_disk|
            if vdev_disk <= Disk.all.size
              disks[vdev_disk] = (disks[vdev_disk] || 0) + vdev.partition_bytes + (legacy_boot ? MBR_SIZE : 0) + (efi_partition ? EFI_SIZE : 0)
            else
              errors << "boot pool vdev #{index + 1} specifies a disk number #{vdev_disk}, but there are only #{Disk.all.size} disks in the system"
            end
          end
        end
        root_pool && root_pool.each_with_index do |vdev, index|
          vdev.disks.each do |vdev_disk|
            if vdev_disk <= Disk.all.size
              disks[vdev_disk] = (disks[vdev_disk] || 0) + vdev.partition_bytes
            else
              errors << "root pool vdev #{index} specifies a disk number #{vdev_disk}, but there are only #{Disk.all.size} disks in the system"
            end
          end
        end
        disks.keys.each do |disk_number|
          if Disk.all[disk_number - 1].capacity_bytes < disks[disk_number]
            errors << "The total space allocated to disk #{disk_number} exceeds it's capacity"
          end
        end
      end
    end
  end

end