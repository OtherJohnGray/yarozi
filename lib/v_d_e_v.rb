class VDEV < Struct.new(:type, :partition_size, :disks)

  B = 1
  K = 1024
  M = K * 1024
  G = M * 1024
  T = G * 1024

  def partition_bytes
    /(?<digits>\d+(?:\.\d+)?)(?<unit>[TGMKB])/ =~ partition_size
    (digits.to_f * self.class.const_get(unit.to_sym)).to_i
  end

end