# This class owns the responsibility of mapping a YVN vdev map to actual disk partitions
class Layout < Struct.new :boot_pool, :root_pool, :legacy_boot, :efi_partition, :swap

  MBR_SIZE = 2**20
  EFI_SIZE = 2**29

  def valid?
    errors.empty?
  end

  def errors
    Array.new.tap do |errors|
      %w(boot root).each do |pool_name|
        if pool = self.send(pool_name + "_pool")
          errors.concat pool.errors.map{|e| "#{pool_name} pool vdev #{e}"}
          pool.each_with_index do |vdev, i|
            unless %w(S M Z1 Z2 Z3).include?( vdev.type.upcase )
              errors << "#{pool_name} vdev #{i + 1} has type #{vdev.type.upcase} which is not valid for a #{pool_name} pool"
            end
          end
        end
      end
      if swap 
        errors.concat swap.errors.map{|e| "swap device #{e}"}
        swap.each_with_index do |vdev, i|
          unless %w(S R1 R5 R6).include?( vdev.type.upcase )
            errors << "swap device #{i + 1} has type #{vdev.type.upcase} which is not valid for swap"
          end
        end
      end
      (1..Disk.all.size).to_a.map{ |n| [n, {allocated:0, wildcards:[] }] }.to_h.tap do |disks|
        boot_pool && boot_pool.each_with_index do |vdev, index|
          vdev.disks.each do |vdev_disk|
            if vdev_disk <= Disk.all.size
              if vdev.partition_bytes == '*'
                disks[vdev_disk][:wildcards] << "boot vdev #{index + 1}"
              else
                disks[vdev_disk][:allocated] += vdev.partition_bytes
              end
              disks[vdev_disk][:allocated] += ( (legacy_boot ? MBR_SIZE : 0) + (efi_partition ? EFI_SIZE : 0) )
            else
              errors << "boot pool vdev #{index + 1} specifies a disk number #{vdev_disk}, but there are only #{Disk.all.size} disks in the system"
            end
          end
        end
        root_pool && root_pool.each_with_index do |vdev, index|
          vdev.disks.each do |vdev_disk|
            if vdev_disk <= Disk.all.size
              if vdev.partition_bytes == '*'
                disks[vdev_disk][:wildcards] << "root vdev #{index + 1}"
              else
                disks[vdev_disk][:allocated] += vdev.partition_bytes
              end
            else
              errors << "root pool vdev #{index} specifies a disk number #{vdev_disk}, but there are only #{Disk.all.size} disks in the system"
            end
          end
        end
        swap && swap.each_with_index do |vdev, index|
          vdev.disks.each do |vdev_disk|
            if vdev_disk <= Disk.all.size
              if vdev.partition_bytes == '*'
                disks[vdev_disk][:wildcards] << "swap device #{index + 1}"
              else
                disks[vdev_disk][:allocated] += vdev.partition_bytes
              end
            else
              errors << "swap device #{index} specifies a disk number #{vdev_disk}, but there are only #{Disk.all.size} disks in the system"
            end
          end
        end
        disks.keys.each do |disk_number|
          if Disk.all[disk_number - 1].capacity_bytes < disks[disk_number][:allocated]
            errors << "The total space allocated to disk #{disk_number} exceeds it's capacity"
          end
          if disks[disk_number][:wildcards].length > 1
            descriptions = disks[disk_number][:wildcards].uniq.map {|description| "#{disks[disk_number][:wildcards].count(description)} from #{description}"}
            descriptions[-1].prepend("and ")
            errors.append "More than one size wildcard (*) specified for disk #{disk_number}: #{descriptions.join ", "}"
          end
        end
      end
    end
  end

end