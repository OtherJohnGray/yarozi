class YVN

  DISK_PATTERN = /\[(\d+,)*(\d+)\]$/
  VDEV_PATTERN = /^(S|M|Z1|Z2|Z3):\d+[TGM]#{DISK_PATTERN}/ 

    def initialize(yvn_string)
      @yvn_string = yvn_string
      @vdev_strings = @yvn_string.gsub(/\s+/m, ' ').strip.split(" ")
    end

    def valid_zpool?
      @vdev_strings.all? {|v| valid_vdev_string? v }
    end

    def valid_vdev_string?(vdev_string)
      # p "vdev_pattern: #{VDEV_PATTERN}"
      # p "vdev match: #{VDEV_PATTERN =~ vdev_string}" 
      # p "disk match: #{vdev_string.match(DISK_PATTERN)}"     
      # p "disk array: #{vdev_string.match(DISK_PATTERN)[1..-1]}"
      # p "size match: #{vdev_string.match(DISK_PATTERN)[1..-1].all?{|n| n.to_i > 0 && n.to_i <= Disk.all.length}}"
      VDEV_PATTERN =~ vdev_string && vdev_string.match(DISK_PATTERN)[1..-1].all?{|n| n.to_i > 0 && n.to_i <= Disk.all.length}
    end

    def zpool_errors
      [].tap do |e|
        @vdev_strings.each_with_index do |v, i|
          [].tap do |a|
            a << "VDEV #{i+1} must start with S, M, Z1, Z2, or Z3" unless /^(S|M|Z1|Z2|Z3)/ =~ v
            a << "VDEV #{i+1} must have : as the 2nd or 3rd character" unless [1,2].include?(v.index(":"))
            a << "VDEV #{i+1} must contain a list of disk numbers, comma separated and inside square brackets" unless DISK_PATTERN =~ v
            a.concat disk_number_errors(v).map{|e| "VDEV #{i+1}: #{e}"} 
            a << "(  for your reference, VDEV #{i+1} was parsed as being #{v}  )" if a.length > 0
            e.concat a
          end
        end
      end
    end

    def disk_number_errors(vdev_string)
      [].tap do |a|
        vdev_string.match(DISK_PATTERN)[1..-1].each_with_index do |n, i|
          a << "disk number of #{n} in position #{i+1} is greater than the number of disks available (#{Disk.all.length})" if n.to_i > Disk.all.length
        end
      end
    end
end