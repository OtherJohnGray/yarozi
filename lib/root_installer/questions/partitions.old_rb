class RootInstaller::Questions::Partitions < Question

    def ask
      wizard.title = "Zpools"
      wizard.default_item = task.root_encryption_type if task.respond_to? :root_encryption_type
      text = <<~TEXT
        (This screen is very long. Use UP and DOWN arrow keys to scroll if needed)

        This screen specifies the disk partitions for the VDEVs of your ZPools. For maximum flexibility, this is done using Yarozi Vdev Notation (YVN). YVN specifies a ZPool as a series of white-space separated VDEV definitions. A VDEV definition is a string in the format

        <VdevType>:<PartitionSize>[Disk#,...]

        VdevType is one of S (for Single partition VDEV), M (for mirror), or R1, R2, or R3 (for RAIDZ 1 through 3 respectively).
        PartitionSize is the size of each SINGLE partition to create, as <size>M (for MiB), <size>G (for GiB), or <size>T (for TiB), or * (for the remaining space on the disk) - for example, 200G means that each individual partition for the VDEV will be 200 GiB. If this was a 5-disk RAIDZ-2 VDEV, then total usable size would bee 600 GiB (5 - 2 multiplied by 200).
        Disk# is the number of the disk shown in the numbered list below. An inclusive range of disk numbers can be specified using a dash, e.g. disks 1 thru 4 can be specified as 1,2,3,4 or as 1-4.

        Examples:

        \\"raid 0\\" ZPool consisting of two single-partition VDEVs, made out of a 100GiB partition on disk 1 and a 100GiB partition on disk 2, with total usable pool size of 200GiB:
        S:100G[1] S:100G[2]

        \\"raid 1\\" ZPool consisting of a single mirror VDEV, made out of a 100GiB partition on disk 1 and a 100GiB partition on disk 2, with total usable pool size of 100GiB:
        M:100G[1,2]

        \\"raid 10\\" ZPool consisting of two 2-partition mirror VDEVs, made out of 100GiB partitions on disks 1 thru 4, with total usable pool size of 200GiB:
        M:100G[1,2] M:100G[3,4]

        RAIDZ1 ZPool consisting of a single 5-partition VDEV, made out of 200GiB partitions on disks 1 thru 5:
        R1:100G[1-5]

      TEXT

      user = ''
      uid = ''
      gid = ''
      home = ENV["HOME"]
      @hsh = {}
      @hsh['Username:'] = user
      @hsh['UID:'] = uid.to_s
      @hsh['GID:'] = gid.to_s
      @hsh['HOME:'] = home

      flen = 60
      form_data = Struct.new(:label, :ly, :lx, :item, :iy, :ix, :flen, :ilen)

      # infinite loop. break out 
      # - if all the values of the form are filled in when OK button is pressed
      # - if Esc button is pressed twice
      loop do
          items = []
          label = "Username:"
          data = form_data.new
          data.label = label
          data.ly = 1
          data.lx = 1
          data.item = @hsh[label]
          data.iy = 1
          data.ix = 10
          data.flen = flen
          data.ilen = 0
          items.push(data.to_a)

          data = form_data.new
          label = "UID:"
          data.label = label
          data.ly = 2 
          data.lx = 1
          data.item = @hsh[label]
          data.iy = 2
          data.ix = 10
          data.flen = flen
          data.ilen = 0
          items.push(data.to_a)

          data = form_data.new
          label = "GID:"
          data.label = label
          data.ly = 3
          data.lx = 1
          data.item = @hsh[label]
          data.iy =3 
          data.ix = 10
          data.flen = flen
          data.ilen = 0
          items.push(data.to_a)

          data = form_data.new
          label = "HOME:"
          data.label = label
          data.ly = 4
          data.lx = 1
          data.item = @hsh[label]
          data.iy = 4
          data.ix = 10
          data.flen = flen
          data.ilen = 0
          items.push(data.to_a)

          height = 45
          width = 200
          formheight = 0
    
          wizard.default_button = false
          @hsh = wizard.input(text, items, height, width, formheight)

          if form_filled?
            puts "Resulting data:"
            @hsh.each do |key, val|
                puts "'#{key}' = #{val}"
            end
            break
          else
            show_warning
          end
      end

    end


    def respond
      task.set :root_encryption_type, @choice
    end




end