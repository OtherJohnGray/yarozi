class RootInstaller::Questions::Partitions < Question

    def ask
      wizard.title = "YAROZI VDEV Notation"
      wizard.default_item = task.root_encryption_type if task.respond_to? :root_encryption_type
      text = <<~TEXT

        (This screen is very long. Use UP and DOWN arrow keys to scroll - PAGEUP and PAGEDOWN keys work also....)

        The following #{task.configure_swap ? "three" : "two"} sceens specify the disk partitions for the VDEVs of your ZPools#{task.configure_swap ? " and swap" : ""}. For maximum flexibility, this is done using Yarozi Vdev Notation (YVN). YVN specifies a ZPool as a series of white-space separated VDEV definitions. A VDEV definition is a string in the format:

        <VdevType>:<PartitionSize>[Disk#,...]

        VdevType is one of S (for Single partition VDEV), M (for mirror), or Z1, Z2, or Z3 (for RAIDZ 1 through 3 respectively).
        
        PartitionSize is the size of each SINGLE partition to create, as <size>M (for MiB), <size>G (for GiB), <size>T (for TiB), or * (for the remaining space on the disk) - for example, 200G means that each individual partition for the VDEV will be 200 GiB. If this was a 5-disk RAIDZ-2 VDEV, then total usable size would be 600 GiB (5 - 2 multiplied by 200).
        
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

        To achieve bit-rot resistance in a space efficient way if you only have a single drive, you can create a RAIDZ1 setup out of multiple partitons on the same drive (instead of using copies=2). for example, this definition allocates 160GiB of usable space and only 20GiB of parity:

        R1:20G[1,1,1,1,1,1,1,1,1]
        #{task.configure_swap ? swap_examples : ""}
        The disk numbers for your disks are as follows:

        #{Disk.to_numbered_list}

        Please get a piece of paper of paper or open a notepad app, and write down now the YVN definitions that you want to use for your #{task.configure_swap ? "Root pool, Boot pool, and Swap" : "Root and Boot pools"}, and then choose next to continue to the pool definition screens. You can use the back button at any time to come back to this screen for reference.

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
      
            input = wizard.input(text, items, height, width, formheight)[name]
    
            break unless clicked == "next"

            if @input = YVN.new(input).valid_zpool?
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
        task.set task_variable, @input
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