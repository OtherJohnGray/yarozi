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
        err << "'single' device must have exactly 1 disk" if type == 'S' && disks.size != 1
        err << "mirror vdev must have at least 2 disks" if type == 'M' && disks.size < 2
        err << "RAIDZ1 vdev must have at least 2 disks" if type == 'Z1' && disks.size < 2
        err << "RAIDZ2 vdev must have at least 3 disks" if type == 'Z2' && disks.size < 3
        err << "RAIDZ3 vdev must have at least 4 disks" if type == 'Z3' && disks.size < 4
        err << "RAID1 volume must have at least 2 disks" if type == 'R1' && disks.size < 2
        err << "RAID5 volume must have at least 2 disks" if type == 'R5' && disks.size < 2
        err << "RAID6 volume must have at least 3 disks" if type == 'R6' && disks.size < 3
      else
        err << "disks must be an array of integers"
      end
    end
  end

end