class YVN
    attr_accessor :yvn_string, :swap, :errors

    def initialize(yvn_string, swap=false)
      @yvn_string = yvn_string
      @swap = swap
      if @yvn_string && @vyvn_string.length > 0
        @vdev_strings = @yvn_string.gsub(/\s+/m, ' ').strip.split(" ")
        @vdevs = @vdev_string.map {|vdev_string| VDEV.new vdev_string }
        @errors = @vdevs.map{|v| v.errors}.flatten
      else
        @errors ["yvn_string was empty"]
      end
    end

    def valid?
      @errors.empty?
    end


    class VDEV
      attr_accessor :vdev_string, :type, :size, :units

      TYPE_PATTERN  = /^(S|M|Z1|Z2|Z3|R1|R5|R6)/
      SIZE_PATTERN  = /(\d+)/
      UNITS_PATTERN = /(T|G|M)/
      NUM_PATTERN   = /(\d+,?)|(\d+)-(\d+),?/
      DISKS_PATTERN = /\[(?:#{NUM_PATTERN}+)\]$/
      VDEV_PATTERN  = /#{TYPE_PATTERN}:\d+#{UNITS_PATTERN}#{DISKS_PATTERN}/ 

      def initialize(vdev_string)
        @vdev_string = vdev_string
        @errors      = []
        @disks       = []

        if m = VDEV_PATTERN.match( vdev_string )
          @type        = m[1]
          @size        = m[2]
          @units       = m[3]
          @disk_string = m[4]
          @disk
          if r = RANGE_PATTERN.match(@disks)
            parse_range_match r
          else
            parse_list_match LIST_PATTERN.match(@disks)
          end
        else
          @errors << "must start with type identifier of S, M, Z1, Z2, Z3, R1, R5, or R6" unless TYPE_PATTERN =~ vdev_string
          @errors << "must have : as the 2nd or 3rd character" unless [1,2].include?(v.index(":"))
          @errors << "must include partition size immediately following the type and : characters" unless /:\d+/ =~ vdev_string
          @errors << "must include size units of M, G, or T immediately following the partition size value" unless /\d+#{UNITS_PATTERN}/ =~ vdev_string
          @errors << "must contain a list of disk numbers, comma separated and inside square brackets, or alternatively a range of disk numbers in format first-last" unless DISKS_PATTERN =~ vdev_string
        end
      end
    end

    def parse_range_match(match_data)
      first, last = match_data[1..-1].map{|m| m.to_i }
      if first < 0
        @errors << "first disk number of #{first} was less than 1"
      elsif first > Disk.count
        @errors << "first disk number of #{first} was greater than the number of disks available (#{Disk.count})"
      end
      if last < 0
        @errors << "last disk number of #{last} was less than 1"
      elsif first > Disk.count
        @errors << "last disk number of #{last} was greater than the number of disks available (#{Disk.count})"
      end
      if first > last
        @disks.concat Range.new(first, last).to_a
      else
        "last disk number of #{last} must be greater than the first disk number of #{first}"
      end
    end

    def parse_list_match(match_data)
      match_data[1..-1].each_with_index do |m, i|
        n = m.to_i
        if if n > Disk.count
          @errors << "disk number of #{m} in position #{i+1} is greater than the number of disks available (#{Disk.count})" 
        elsif n < 1
          @errors << "disk number of #{m} in position #{i+1} is less than 1" 
        else
          @disks << n
        end
        
      end
    end


  end


end