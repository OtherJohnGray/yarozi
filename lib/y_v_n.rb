class YVN
  attr_accessor :yvn_string, :segments, :errors, :zpool

  def initialize(yvn_string)
    @yvn_string = yvn_string
    if @yvn_string && @yvn_string.length > 0
      @vdev_strings = @yvn_string.gsub(/\s+/m, ' ').strip.split(" ")
      @segments = @vdev_strings.map {|vdev_string| Segment.new(vdev_string) }
      @errors = @segments.map(&:errors).flatten
      @zpool = ZPool.new @segments.map(&:vdev) if valid? 
    else
      @errors = ["was empty"]
    end
  end

  def valid?
    @errors.empty?
  end

  def invalid?
    !valid?
  end

  def to_s
    @yvn_string
  end


  class Segment
    attr_accessor :vdev_string, :vdev, :errors

    TYPE_PATTERN     = /^(S|M|Z1|Z2|Z3|R1|R5|R6)/
    SIZE_PATTERN     = /(\d+(?:\.\d+)?[TGMKB]|\*)/
    DISKNUM_PATTERN  = /\d+/
    RANGE_PATTERN    = /\d+-\d+/
    DISK_PATTERN     = /(?:#{DISKNUM_PATTERN}|#{RANGE_PATTERN}),?/
    DISKS_PATTERN    = /\[(#{DISK_PATTERN}+)\]$/
    VDEV_PATTERN     = /#{TYPE_PATTERN}:#{SIZE_PATTERN}#{DISKS_PATTERN}/ 

    def initialize(vdev_string)
      @vdev_string = vdev_string
      @errors      = []
      if m = VDEV_PATTERN.match( vdev_string )
        @vdev = VDEV.new
        @vdev.type = m[1]
        @vdev.partition_size = m[2]
        @vdev.disks = Array.new.tap do |d|
          m[3].split(',').each do |s|
            if RANGE_PATTERN =~ s
              d.concat Range.new( *s.split("-").map(&:to_i) ).to_a
            else
              d.append s.to_i
            end
          end
        end
        if @vdev.type == 'S' and @vdev.disks.size != 1
          @errors << "must have exactly one disk if type is S"
        end
      else
        @errors << "must start with type identifier of S, M, Z1, Z2, Z3, R1, R5, or R6" unless TYPE_PATTERN =~ vdev_string
        @errors << "must have : immediately following the type identifier" unless [1,2].include?(vdev_string.index(":"))
        @errors << "must include partition size (either * or numbers followed by one of T,G,M,K or B ) immediately following the type and : characters" unless SIZE_PATTERN =~ vdev_string
        @errors << "must contain a list of disk numbers and/or dashed ranges, comma separated and inside square brackets" unless DISKS_PATTERN =~ vdev_string
      end
    end
  end
end

