class RootInstaller::Questions::Partitions < Question

  def reset
    subquestions.reject!{|s| [swap_type, swap_disks, swap_size, swap_add, swap_yvn].include? s } unless task.configure_swap?
  end

  def ask
    wizard.title = "Disk Partitions"
    wizard.default_item = @partitions_type if @partitions_type
    text = <<~TEXT

      You can specify on which disks the installer should place your 
      boot pool, root pool, and swap partitions in two different ways.

      The first is to select the drives from a list. This is good for simple setups, e.g. a single drive, a mirror or striped mirror, or a single small RAIDZ VDEV. 

      The second way is using Yarozi VDEV Notation (tm?), which is a Simple Syntax for Complex Configuration. If you choose this option, The YVN manual will be shown on the next screen.

      How yould you like to choose the disks for your pools?
    TEXT

    items = [
      ["checkbox", "Select drives from a list"],
      ["yvn", "Use Yarozi VDEV Notation"],
    ]

    height = 21
    width = 76
    menu_height = 2
   
    @partitions_type = wizard.ask(text, items, height, width, menu_height)
  end

  def respond
    task.set :layout, Layout.new
    case @partitions_type
    when "yvn"
      subquestions.reject!{|q| [ boot_type, boot_disks, boot_size, boot_add, root_type, root_disks, root_size, root_add, swap_type, swap_disks, swap_size, swap_add ].include? q }
      [yvn_manual, boot_yvn, root_yvn].concat(task.configure_swap? ? [swap_yvn] : []).each{|q| subquestions.append q unless subquestions.include? q }
    else
      subquestions.reject!{|q| [yvn_manual, boot_yvn, root_yvn, swap_yvn].include? q }
      [boot_type, boot_disks, boot_size, boot_add, root_type, root_disks, root_size, root_add].concat(task.configure_swap? ? [swap_type, swap_disks, swap_size, swap_add] : []).each{|q| subquestions.append q unless subquestions.include? q }
    end
  end


# Subquestions ###############################################################
# create caching reader methods in the form:
#   def boot_type
#     @boot_type ||= BootType.new(1, task)
#   end 
# etc. etc. etc.

  def yvn_manual
    @yvn_manual ||= YVNManual.new(task)
  end

  %w(boot root swap).each do |pool|
    %w(type disks size add).each do |screen|
      define_method "#{pool}_#{screen}".to_sym, ->{ instance_variable_get("@#{pool}_#{screen}".to_sym) || instance_variable_set( "@#{pool}_#{screen}".to_sym, self.class.const_get( "#{pool.capitalize}#{screen.capitalize}".to_sym ).new(1, task) ) }
      define_method "#{pool}_yvn".to_sym, ->{ instance_variable_get("@#{pool}_yvn".to_sym) || instance_variable_set( "@#{pool}_yvn".to_sym, self.class.const_get( "#{pool.capitalize}YVN".to_sym ).new(task) ) }
    end
  end 

# Inner Classes ##############################################################

  class PartitionQuestion < Question
    def initialize(vdev_number, task)
      super(task)
      @vdev_number = vdev_number
    end

    def vdev
      raise "out of order question display" unless pool.size == @vdev_number
      pool[ @vdev_number - 1 ]
    end

    def reset
      #noop
    end
  end


  class TypeQuestion < PartitionQuestion
    def reset
      pool.delete_at @vdev_number - 1
    end
    
    def ask
      wizard.title = title
      wizard.default_item = @choice if @choice
      @choice = wizard.ask(text, items, height, width, menu_height)
    end

    def respond
      raise "out of order question display" unless pool.size == @vdev_number - 1
      pool << VDEV.new
      vdev.type = @choice
    end

    def text
      "\nWhat type of VDEV should #{title} be?"
    end

    def items
      [
        ["S", "Single partition VDEV"],
        ["M", "Mirror VDEV over multiple partitions"],
        ["Z1", "RAIDZ1 VDEV over multiple partitions"],
        ["Z2", "RAIDZ2 VDEV over multiple partitions"],
        ["Z3", "RAIDZ3 VDEV over multiple partitions"]
      ]
    end

    def height
      13
    end

    def width
      76
    end

    def menu_height
      5      
    end
  end


  module BootParams
    def title
      "Boot Pool VDEV #{@vdev_number}"
    end

    def pool
      task.layout.boot_pool ||= ZPool.new
    end
  end

  module RootParams
    def title
      "Root Pool VDEV #{@vdev_number}"
    end

    def pool
      task.layout.root_pool ||= ZPool.new
    end
  end
  
  module SwapParams
    def title
      "Swap device #{@vdev_number}"
    end

    def pool
      task.layout.swap ||= ZPool.new
    end
  end

  class BootType < TypeQuestion
    include BootParams
  end


  class RootType < TypeQuestion
  include RootParams
  end


  class SwapType < TypeQuestion
    include SwapParams

    def text
      <<~TEXT
        What type of device should swap device #{@vdev_number} be?
        (#{@vdev_number == 1 ? "If you add more devices after this one, swap will be striped across all of them" : "Swap will be swapped across all the devices you create"})
      TEXT
    end

    def items
      [
        ["S", "Single raid device on 1 partition"],
        ["R1", "\"Mirrored\" RAID1 mdraid device on multiple partitions"],
        ["R5", "RAID5 mdraid device on multiple partitions"],
        ["R6", "RAID6 mdraid device on multiple partitions"],
      ]
    end

    def height
      21
    end

    def menu_height
      4
    end
  end


  class DisksQuestion < PartitionQuestion
    def ask
      wizard.title = title
      loop do
        items = [].tap do |disks|
          Disk.to_strings.each_with_index do |disk_name, idx|
            disks << [ idx + 1, disk_name, (@selected_disks ||= []).include?((idx + 1).to_s) ]
          end
        end
        @selected_disks = wizard.list(text, items, height, width, list_height)

        break unless clicked == "next"
        if @selected_disks.empty?
          new_dialog.alert "No disks were selected", 5, 26
        elsif vdev.type == 'S' && @selected_disks.size != 1
          new_dialog.alert "#{title} is a 'single' device and should have exactly 1 disk, but it has #{@selected_disks.size} instead", 6, 78
        elsif vdev.type == 'M' && @selected_disks.size < 2
          new_dialog.alert "#{title} is a mirror and should have at least 2 disks, but it only has 1", 6, 78
        elsif vdev.type == 'Z1' && @selected_disks.size < 2
          new_dialog.alert "#{title} is RAIDZ1 and should have at least 2 disks, but it only has 1", 6, 78
        elsif vdev.type == 'Z2' && @selected_disks.size < 3
          new_dialog.alert "#{title} is RAIDZ2 and should have at least 3 disks, but it only has #{@selected_disks.size}", 6, 78
        elsif vdev.type == 'Z3' && @selected_disks.size < 4
          new_dialog.alert "#{title} is RAIDZ3 and should have at least 4 disks, but it only has #{@selected_disks.size}", 6, 78
        elsif vdev.type == 'R1' && @selected_disks.size < 2
          new_dialog.alert "#{title} is RAID1 volume and should have at least 2 disks, but it only has 1", 6, 78
        elsif vdev.type == 'R5' && @selected_disks.size < 2
          new_dialog.alert "#{title} is RAID5 volume and should have at least 2 disks, but it only has 1", 6, 78
        elsif vdev.type == 'R6' && @selected_disks.size < 3
          new_dialog.alert "#{title} is RAID6 volume and should have at least 3 disks, but it only has #{@selected_disks.size}", 6, 78
        else
          break
        end
      end
    end

    def respond
      vdev.disks = @selected_disks.map(&:to_i)
    end

    def text
      <<~TEXT

      Which disks should be used for #{title} partitions?
      TEXT
    end

    def height
      22
    end

    def width
      120
    end

    def list_height
      15     
    end


  end


  class BootDisks < DisksQuestion
    include BootParams
  end

  class RootDisks < DisksQuestion
    include RootParams
  end

  class SwapDisks < DisksQuestion
    include SwapParams
  end


  class SizeQuestion < PartitionQuestion

    def ask
      wizard.title = title
      wizard.default_button = false
      form_data = Struct.new(:label, :ly, :lx, :item, :iy, :ix, :flen, :ilen)
      loop do
        items = []
        data = form_data.new
        data.label = name
        data.ly = 1
        data.lx = 1
        data.item = @size ? @size : ""
        data.iy = 1
        data.ix = name.length + 2
        data.flen = 67 - name.length
        data.ilen = 9999
        items.push(data.to_a)
        width = 76
        formheight = 1
        @size = wizard.input(text, items, height, width, formheight)[name].upcase.strip

        break unless clicked == "next"

        if /^\d+[TGMKB*]|\*$/ =~ @size
          vdev.partition_size = @size
          if vdev.valid?
            if task.layout.valid?
              break
            else
              show_errors @task.layout.errors
            end
          else
            show_errors vdev.errors.map{|e| "#{title} #{e}"}
          end
        else
          if @size.length == 0
            new_dialog.alert "Please provide a partition size, e.g. 1TB, 200G etc, or * for rest of disk", 7, 78
          elsif /\d+/ =~ @size
            new_dialog.alert "input value #{@size} did not include a unit type\n(T,G,M,K, or B)", 7, 64
          else
            new_dialog.alert "Input value #{@size} is not a valid partiton size", 7, 60
          end
        end
      end
    end

    def show_errors(errors)
      text = <<~TEXT
        
        Please correct the following errors:

        #{errors.join "\n"}
      TEXT
      new_dialog.alert text, 100, 200
    end

    def name
      "Partition Size:"
    end

    def respond
    end

    def text
      <<~TEXT

      How large should each #{title} partition be? 
      
      You can specify partition size entering a number followed by the letter T (for TiB), G (for GiB), M (for MiB), K (for KiB), or B (for bytes).
      
      Alternatively, you can enter * to use all remaining space on each disk.
      TEXT
    end

    def height
      14
    end

    def width
      78
    end

    
  end


  class BootSize < SizeQuestion
    include BootParams
  end

  class RootSize < SizeQuestion
    include RootParams
  end

  class SwapSize < SizeQuestion
    include SwapParams
  end


  class AddQuestion < PartitionQuestion

    def ask
      wizard.title = pool_name
      @choice = wizard.ask(text, items, height, width, menu_height)
    end

    def respond
      if @choice == "yes"
        subquestions.concat another
      else
        subquestions.clear
      end
    end

    def device_type
      "VDEV"
    end

    def text
      "\nWould you like to add a #{device_type} #{@vdev_number + 1} to #{pool_name}?"
    end
  
    def height
      10
    end
    
    def width
      64
    end
    
    def menu_height
      2
    end
    
    def items
      [
        ["yes", "Add another #{device_type} to #{pool_name}"],
        ["no", "No, #{pool_name} is complete"]
      ]      
    end
  end



  class BootAdd < AddQuestion
    include BootParams

    def pool_name
      "Boot Pool"
    end

    def another
      @another ||= [ 
        BootType.new(@vdev_number + 1, task), 
        BootDisks.new(@vdev_number + 1, task), 
        BootSize.new(@vdev_number + 1, task), 
        BootAdd.new(@vdev_number + 1, task) 
      ]
    end
  end

  class RootAdd < AddQuestion
    include RootParams

    def pool_name
      "Root Pool"
    end

    def another
      @another ||= [ 
        RootType.new(@vdev_number + 1, task), 
        RootDisks.new(@vdev_number + 1, task), 
        RootSize.new(@vdev_number + 1, task), 
        RootAdd.new(@vdev_number + 1, task) 
      ]
    end
  end

  class SwapAdd < AddQuestion
    include SwapParams

    def pool_name
      "swap"
    end

    def device_type
      "device"
    end

    def another
      @another ||= [ 
        SwapType.new(@vdev_number + 1, task), 
        SwapDisks.new(@vdev_number + 1, task), 
        SwapSize.new(@vdev_number + 1, task), 
        SwapAdd.new(@vdev_number + 1, task) 
      ]
    end
  end



  class YVNManual < Question

    def ask
      wizard.title = "YAROZI VDEV Notation"
      text = <<~TEXT

        (This screen is very long. Use UP and DOWN arrow keys to scroll - PAGEUP and PAGEDOWN keys work also....)

        The following #{task.configure_swap? ? "three" : "two"} sceens specify the disk partitions for the VDEVs of your ZPools#{task.configure_swap? ? " and swap" : ""}. For maximum flexibility, this is done using Yarozi Vdev Notation (YVN). YVN specifies a ZPool as a series of white-space separated VDEV definitions. A VDEV definition is a string in the format:

        <VdevType>:<PartitionSize>[Disk#,...]

        VdevType is one of S (for Single partition VDEV), M (for mirror), or Z1, Z2, or Z3 (for RAIDZ 1 through 3 respectively).
        
        PartitionSize is the size of each SINGLE partition to create, as <size>T (for TiB), <size>G (for GiB), <size>M (for MiB), <size>K (for KiB), <size>B (for Bytes) or * (for the remaining space on the disk) - for example, 200G means that each individual partition for the VDEV will be 200 GiB. If this was a 5-disk RAIDZ-2 VDEV, then total usable size would be 600 GiB (5 - 2 multiplied by 200).
        
        Disk# is the number of the disk shown in the numbered list below. An inclusive range of disk numbers can be specified using a dash, e.g. disks 1 thru 4 can be specified as 1,2,3,4 or as 1-4. You can also mix and match these notations as needed to describe non-contiguous ranges, e.g. [1,4-6,11-15,22]

        Examples:

        To define a \\"raid 0\\" ZPool consisting of two single-partition VDEVs, made out of a 100GiB partition on disk 1 and a 100GiB partition on disk 2, with total usable pool size of 200GiB:

        S:100G[1] S:100G[2]

        To define a \\"raid 1\\" ZPool consisting of a single mirror VDEV, made out of a 100GiB partition on disk 1 and a 100GiB partition on disk 2, with total usable pool size of 100GiB:

        M:100G[1,2]

        To define a \\"raid 10\\" ZPool consisting of two 2-partition mirror VDEVs, made out of 100GiB partitions on disks 1 thru 4, with total usable pool size of 200GiB:

        M:100G[1,2] M:100G[3,4]

        To define a RAIDZ2 ZPool consisting of a single 6-partition VDEV, made out of 100GiB partitions on disks 1 thru 6:

        Z2:100G[1-6]

        To define a twin RAIDZ1 ZPool consisting of two 8-partition VDEVs, made out of 100GiB partitions on non-adjacent disks:

        Z1:100G[1-3,6,11-14] Z1:100G[30-36,42]

        To achieve bit-rot resistance in a space efficient way if you only have a single drive, you can create a RAIDZ1 setup out of multiple partitions on the same drive (instead of using copies=2). for example, this definition allocates 160GiB of usable space and only 20GiB of parity:

        R1:20G[1,1,1,1,1,1,1,1,1]
        #{task.configure_swap? ? swap_examples : ""}
        The disk numbers for your disks are as follows:

        #{Disk.to_numbered_list}

        Please get a piece of paper of paper or open a notepad app, and write down now the YVN definitions that you want to use for your #{task.configure_swap? ? "Root pool, Boot pool, and Swap" : "Root and Boot pools"}, and then choose next to continue to the pool definition screens. You can use the back button at any time to come back to this screen for reference.

      TEXT

      wizard.advise(text, 100, 150)
    end

    def swap_examples
      <<~TEXT

        For swap, YVN is interperated as defining either raw partitions or MDRAID volumes. Use one or more S: definitions to stripe swap across raw partitions, or use one or more R1 (RAID1), R5 (RAID5), or R6 (RAID6) definitions to place swap on MDRAID volumes.

        e.g. single 240 GiB swap partition on disk 1 without redundancy: S:240G[1]

        e.g. stripe swap across two separate RAID1 "mirrors": R1:120G[1,2] R1:120G[3,4]

        e.g. use a 6-partition RAID6 volume for swap: R6:60G[1-6]

      TEXT
    end

      
  end


  class YVNQuestion < Question
    def ask
      wizard.title = name
      wizard.default_button = false
      form_data = Struct.new(:label, :ly, :lx, :item, :iy, :ix, :flen, :ilen)

      loop do
        text = <<~TEXT
          #{preamble}
        TEXT
        items = []
        data = form_data.new
        data.label = name
        data.ly = 1
        data.lx = 1
        data.item = @yvn ? @yvn : ""
        data.iy = 1
        data.ix = name.length + 2
        data.flen = 67 - name.length
        data.ilen = 9999
        items.push(data.to_a)
        width = 76
        formheight = 1
        input = wizard.input(text, items, height, width, formheight)[name]

        break unless clicked == "next"

        if (@yvn = YVN.new(input.upcase)).invalid?
          show_errors @yvn.errors.map{|e| "YVN segments " + e}
        else
          task.layout.send assign_layout, @yvn.zpool
          if task.layout.invalid?
            show_errors @task.layout.errors
          else
            break
          end
        end
      end
    end

    def show_errors(errors)
      text = <<~TEXT
        
        Please correct the following errors:

        #{errors.join "\n"}
      TEXT
      new_dialog.alert text, 100, 200
    end

    def vdev_syntax
      <<~TEXT
        YVN VDEV Syntax reminder: <type>:<partition size>[Disk#....]

        e.g. Single disk: S:100G[1]
        
        e.g. 2 disk mirror: M:100G[1,2]
        
        e.g. 6 disk RAIDZ2: Z2:100G[1-6]
        
        e.g. 2 disks striped: S:50G[1] S:50G[2]
      TEXT
    end      

    def swap_syntax
      <<~TEXT
        YVN Swap Syntax reminder: <type>:<partition size>[Disk#....]

        e.g. Single disk: S:100G[1]
        
        e.g. 2 disks striped: S:100G[1] S:100G[2]
        
        e.g. 2 disks mirrored with RAID5: R5:100G[1,2]

        e.g. 6 disk RAID6: R6:100G[1-6]
      TEXT
    end      
  end


  class BootYVN < YVNQuestion
    def name
      "Boot pool"
    end

    def assign_layout
      :boot_pool=
    end

    def preamble
      <<~TEXT
        Please enter the YVN definition that you want for your Boot pool.
        #{task.boot_type == "efi" ? "EFI partitions" : "Master Boot Records #{ task.efi_partition == "yes" ? "and future-use EFI partitions " : "" }"} will also be created on the disks that you select, and will use.

        #{vdev_syntax}
      TEXT
    end

    def height
        task.boot_type == "mbr" && task.efi_partition == "yes" ? 22 : 20
    end
  end
  
  class RootYVN < YVNQuestion
    def name
      "Root pool"
    end

    def assign_layout
      :boot_pool=
    end

    def preamble
      <<~TEXT
        Please enter the YVN definition that you want for your Root pool.

        #{vdev_syntax}
      TEXT
    end

    def height
      18
    end
  end
  
  
  class SwapYVN < YVNQuestion
    def name
      "Swap"
    end

    def assign_layout
      :swap=
    end

    def preamble
      <<~TEXT
        Please enter the YVN definition that you want for your Swap devices.

        #{swap_syntax}
      TEXT
    end

    def height
      18
    end
  end







end