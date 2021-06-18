// This class owns the responsibility of mapping a YVN vdev map to actual disk partitions
class Layout

  def initialize(VYN yvn)
    @vdevs = yvn.vdevs
  end

end