class RootInstaller::Questions::Partitions < Question

    def ask
      wizard.title = "YAROZI VDEV Notation"
      wizard.default_item = task.root_encryption_type if task.respond_to? :root_encryption_type
      text = <<~TEXT

        (This screen is very long. Use UP and DOWN arrow keys to scroll - PAGEUP and PAGEDOWN keys work also....)

        The following #{task.configure_swap ? "three" : "two"} sceens specify the disk partitions for the VDEVs of your ZPools#{task.configure_swap ? " and swap" : ""}. For maximum flexibility, this is done using Yarozi Vdev Notation (YVN). YVN specifies a ZPool as a series of white-space separated VDEV definitions. A VDEV definition is a string in the format:

        <VdevType>:<PartitionSize>[Disk#,...]

        VdevType is one of S (for Single partition VDEV), M (for mirror), or R1, R2, or R3 (for RAIDZ 1 through 3 respectively).
        
        PartitionSize is the size of each SINGLE partition to create, as <size>M (for MiB), <size>G (for GiB), <size>T (for TiB), or * (for the remaining space on the disk) - for example, 200G means that each individual partition for the VDEV will be 200 GiB. If this was a 5-disk RAIDZ-2 VDEV, then total usable size would be 600 GiB (5 - 2 multiplied by 200).
        
        Disk# is the number of the disk shown in the numbered list below. An inclusive range of disk numbers can be specified using a dash, e.g. disks 1 thru 4 can be specified as 1,2,3,4 or as 1-4.

        Examples:

        To define a \\"raid 0\\" ZPool consisting of two single-partition VDEVs, made out of a 100GiB partition on disk 1 and a 100GiB partition on disk 2, with total usable pool size of 200GiB:

        S:100G[1] S:100G[2]

        To define a \\"raid 1\\" ZPool consisting of a single mirror VDEV, made out of a 100GiB partition on disk 1 and a 100GiB partition on disk 2, with total usable pool size of 100GiB:

        M:100G[1,2]

        To define a \\"raid 10\\" ZPool consisting of two 2-partition mirror VDEVs, made out of 100GiB partitions on disks 1 thru 4, with total usable pool size of 200GiB:

        M:100G[1,2] M:100G[3,4]

        To define a RAIDZ2 ZPool consisting of a single 5-partition VDEV, made out of 200GiB partitions on disks 1 thru 6:

        R1:100G[1-6]

        To achieve bit-rot resistance in a space efficient way if you only have a single drive, you can create a RAIDZ1 setup out of multiple partitons on the same drive (instead of using copies=2). for example, this definition allocates 160GiB of usable space and only 20GiB of parity:

        R1:20G[1,1,1,1,1,1,1,1,1]


        The disk numbers for your disks are as follows:

        #{Disk.to_numbered_list}

        Please get a piece of paper of paper or open a notepad app, and write down now the YVN definitions that you want to use for your #{task.configure_swap ? "Root pool, Boot pool, and MDRAID Swap" : "Root and Boot pools"}, and then choose next to continue to the pool definition screens. You can use the back button at any time to come back to this screen for reference.

      TEXT

      wizard.advise(text, 100, 150)
    end

    def respond
      subquestions.append Root.new(task)
      subquestions.append Boot.new(task)
      subquestions.append Swap.new(task) if task.configure_swap
    end


    class YVN < Question
      def ask
        wizard.title = name
        wizard.default_button = false
        text = <<~TEXT

          #{preamble}        

          YVN Syntax reminder: <type>:<partition size>[Disk#....]

          e.g. Single disk: S:100G[1]
          
          e.g. 2 disk mirror: M:100G[1,2]
          
          e.g. 6 disk RAIDZ2: R2:100G[1-6]
          
          e.g. 2 disks striped: S:50G[1] S:50G[2]

        TEXT
    
        form_data = Struct.new(:label, :ly, :lx, :item, :iy, :ix, :flen, :ilen)
    
        # infinite loop. break out 
        # - if all the values of the form are filled in when OK button is pressed
        # - if Esc button is pressed twice
        loop do
            items = []
            data = form_data.new
            data.label = name
            data.ly = 1
            data.lx = 1
            data.item = task.respond_to?(task_variable) ? task.send(task_variable) : ""
            data.iy = 1
            data.ix = name.length + 2
            data.flen = 67 - name.length
            data.ilen = 9999
            items.push(data.to_a)
    
            width = 76
            formheight = 1
      
            @input = wizard.input(text, items, height, width, formheight)[name]
    
            if form_filled? || clicked != "next"
              puts "Resulting data: #{@input}"
              break
            else
              show_warning
            end
        end

      end

      def form_filled?
        true
      end
    
      def respond
        task.set :root_encryption_type, @choice
      end
    
    end
    
    class Boot < YVN
      def name
        "Boot pool"
      end

      def task_variable
        :boot_pool_yvn
      end

      def preamble
        <<~TEXT
          Please enter the YVN definition that you want for your Boot pool.
          #{task.boot_type == "efi" ? "EFI partitions" : "Master Boot Records #{ task.efi_partition == "yes" ? "and future-use EFI partitions " : "" }"} will also be created on the disks that you select.
        TEXT
      end

      def height
          task.boot_type == "mbr" && task.efi_partition == "yes" ? 22 : 20
      end
    end
    
    class Root < YVN
      def name
        "Root pool"
      end

      def task_variable
        :root_pool_yvn
      end
    end
    
    
    class Swap < YVN
      def name
        "Swap"
      end

      def task_variable
        :swap_yvn
      end
    end
    
end