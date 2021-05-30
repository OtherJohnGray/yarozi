class RootInstaller::Questions::YVN < Question

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

        To define a RAIDZ1 ZPool consisting of a single 5-partition VDEV, made out of 200GiB partitions on disks 1 thru 5:

        R1:100G[1-5]

        The disk numbers for your disks are as follows:

        #{Disk.to_numbered_list}

        Please get a piece of paper of paper or open a notepad app, and write down now the YVN definitions that you want to use for your #{task.configure_swap ? "Root pool, Boot pool, and Swap" : "Root and Boot pools"}, and then click next to continue to the pool definition screens. You can use the Back button at any time to come back to this screen for reference.

      TEXT

      wizard.advise(text, 100, 150)

    end



end