class Disk

  attr_accessor :model_name, :serial, :vendor, :device, :driver, :by_serial, :by_uuid, 
                :by_path, :sectors, :sector_size, :capacity_gb, :capacity_bytes

  def to_s
    "#{sprintf('%6d', capacity_gb)} GB #{sprintf('%4s', connection)} #{type} #{id} with #{sector_size} byte sectors as #{device}"
  end

  def self.to_strings
    all.select(&:by_serial).sort_by{|d| d.type_sort_order * 100000000 + d.connection_sort_order * 10000000 + d.capacity_gb}.map(&:to_s)
  end

  def self.to_string_list
    to_strings.join("\n")
  end

  def self.all
    @disks ||= load
  end

  def self.reload
    @disks = load
  end

  def self.load
    disks = []
      log.debug "****** DISK INFO ********"
      log.debug "    "
    disk_hwinfo().each do |info|
      log.debug info.inspect
      log.debug "    "
      disks << info.to_disk 
      log.debug disks[-1].inspect + ", type=#{disks[-1].type}"
      log.debug "-----------------------------------------"
      log.debug "    "
    end
    disks
  end

  def id
    by_serial ? by_serial.delete_prefix('/dev/disk/by-id/') : ""
  end

  def uuid
    by_uuid ? by_uuid.delete_prefix('/dev/disk/by-id/') : ""
  end

  def hdd?
    rotation
  end

  def ssd?
    !rotation
  end

  def connection
    case driver
      when 'nvme', 'usb'
        driver  
      when "ahci"
        "sata"
      else
        if /^nvme/ =~ id 
          'nvme'
        elsif /^ata/ =~ id
          'sata'  
        else 
          '???'
        end
    end
  end

  def connection_sort_order
    case connection
      when 'nvme'
        1
      when 'sata'
        2
      when 'usb'
        3
      else
        4
    end 
  end

  def rotation
    (`lsblk -d -n -o rota /dev/#{device}`).include? "1"    
  end

  def type
    rotation ? "HDD" : "SSD"
  end

  def type_sort_order
    rotation ? 2 : 1
  end

  def self.disk_hwinfo
    get_hwinfo.split("\n\n").map {|info| HWInfo.new(info) }
  end

  # for test stubbing
  def self.get_hwinfo
    `hwinfo --disk`
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
      device_files.select {|str| /by-id\/(wwn|nvme-eui)/ =~ str}.first
    end

    def by_serial
      device_files.select {|str| /by-id/ =~ str}.reject {|str| /by-id\/(wwn|nvme-eui)/ =~ str}.first
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
      @device_files ||= self["Device Files"] ? self["Device Files"].split(", ") : []
    end

  end


end


