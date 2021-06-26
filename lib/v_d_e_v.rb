class VDEV < Struct.new(:type, :partition_size, :disks)

  B = 1
  K = 1024
  M = K * 1024
  G = M * 1024
  T = G * 1024

  def partition_bytes
    return '*' if '*' == partition_size
    /(?<digits>\d+(?:\.\d+)?)(?<unit>[TGMKB])/ =~ partition_size
    (digits.to_f * self.class.const_get(unit.to_sym)).to_i
  end

  def valid?
    errors.empty?
  end

  def errors(vdev_number = "")
    [].tap do |err|
      err << "type must be one of S, M, Z1, Z2, Z3, R1, R5 or R6" unless /S|M|Z1|Z2|Z3|R1|R5|R6/ =~ type
      err << "partition size must be either a number followed by T, G, M, K or B, or else a *" unless /\*|\d+[TGMKB]/ =~ partition_size
      if disks && disks.is_a?(Array) && disks.length > 0 && disks.all?{|d| d.is_a? Integer}
        err << "is a 'single' device and should have exactly 1 disk, but it has #{disks.size} instead" if type == 'S' && disks.size != 1
        err << "is a mirror and should have at least 2 disks, but it only has 1" if type == 'M' && disks.size < 2
        err << "is RAIDZ1 and should have at least 2 disks, but it only has 1" if type == 'Z1' && disks.size < 2
        err << "is RAIDZ2 and should have at least 3 disks, but it only has #{disks.size}" if type == 'Z2' && disks.size < 3
        err << "is RAIDZ3 and should have at least 4 disks, but it only has #{disks.size}" if type == 'Z3' && disks.size < 4
        err << "is RAID1 volume and should have at least 2 disks, but it only has 1" if type == 'R1' && disks.size < 2
        err << "is RAID5 volume and should have at least 2 disks, but it only has 1" if type == 'R5' && disks.size < 2
        err << "is RAID6 volume and should have at least 3 disks, but it only has #{disks.size}" if type == 'R6' && disks.size < 3
      else
        err << "disks must be an array of integers"
      end
    end
  end

end