class Disk

  attr_accessor :model_name, :serial, :vendor, :device, :driver, :by_serial, :by_uuid, 
                :by_path, :sectors, :sector_size, :capacity_gb, :capacity_bytes, :rotation

  def self.all
    @disks ||= load
  end

  def self.reload
    @disks = load
  end

  def self.load
    disks = []
    disk_hwinfo().each do |info|
      puts info.inspect
      puts
      disks << info.to_disk 
      puts disks[-1].inspect + ", type=#{disks[-1].type}"
      puts
      puts
    end
    disks
  end

  def hdd?
    rotation
  end

  def ssd?
    !rotation
  end

  def type
    rotation ? "hdd" : "ssd"
  end



  def self.disk_hwinfo
    `hwinfo --disk`.split("\n\n").map {|info| HWInfo.new(info) }
  end




  class HWInfo < Hash

    def initialize(info)
       info.split("\n")[2..-1].each do |line|
         if /^  (?<key>[^ ].*?):[ ]?(?<value>.*)$/ =~ line
           self[key] = value unless value.empty? 
         end
       end
    end

    def to_disk
      Disk.new.tap do |d|
        d.device = device
        d.model_name = model_name
        d.vendor = vendor
        d.serial = serial
        d.driver = driver
        d.by_path = by_path
        d.by_uuid = by_uuid
        d.by_serial = by_serial
        d.sector_size = sector_size
        d.sectors = sectors
        d.capacity_gb = capacity_gb
        d.capacity_bytes = capacity_bytes
        d.rotation = (`lsblk -d -n -o rota /dev/#{device}`).include? "1"
      end
    end    

    def device 
      self["SysFS ID"].delete_prefix "/class/block/"
    end

    def model_name
      self["Model"].gsub(/"/, '')
    end

    def vendor
      extract_from_quotes self["Vendor"]
    end

    def serial
      extract_from_quotes self["Serial ID"]
    end    

    def driver
      extract_from_quotes self["Driver"]
    end

    def by_path
      device_files.select {|str| /by-path/ =~ str  }.first
    end

    def by_uuid
      device_files.select {|str| /by-id\/wwn/ =~ str}.first
    end

    def by_serial
      device_files.select {|str| /by-id/ =~ str}.reject {|str| /by-id\/wwn/ =~ str}.first
    end

    def sector_size
      /^\d+ sectors a (?<sector_size>\d+) bytes/ =~ self["Size"]
      sector_size.to_i
    end

    def sectors
      /^(?<sectors>\d+) sectors a \d+ bytes/ =~ self["Size"]
      sectors.to_i
    end

    def capacity_gb
      /^(?<gb>\d+) GB \(\d+ bytes\)/ =~ self["Capacity"]
      gb.to_i
    end

    def capacity_bytes
      /^\d+ GB \((?<bytes>\d+) bytes\)/ =~ self["Capacity"]
      bytes.to_i
    end

    def extract_from_quotes(str)
      /.*?"(?<value>.*?)"/ =~ str
      value
    end

    def device_files
      @device_files ||= self["Device Files"].split(", ")
    end

  end


end


