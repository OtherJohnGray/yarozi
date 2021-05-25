class RootInstaller::Questions::BootType < Question

  def ask
    if efi_support?
      if has_512k?
        subquestions.append AskEfi.new(task)
      else
        subquestions.append AdviseEfi.new(task)
      end
    else
      if has_512k?
        subquestions.append AdviseMbr.new(task)
      else
        subquestions.append AdviseError.new(task)
      end
    end
  end

  def efi_support?
    File.directory?("/sys/firmware/efi")
  end

  def has_512k?
    Disk.all.any? {|d| d.sector_size == 512}
  end


  class AskEfi < Question

    def ask
      wizard.title = "Boot Type"
      items = [
        ["efi", "EFI Boot"],
        ["mbr", "Legacy MBR Boot"]
      ]
      height = 11
      width = 50
      menu_height = 2
      text = "\\nThis machine supports both EFI and legacy MBR booting. What boot type would you like?"
      @choice = wizard.ask(text, items, height, width, menu_height)
    end

    def respond 
      task.set :boot_type, @choice
      subquestions.append AskEfiPartition.new(task) if "mbr".eql? @choice
    end

  end


  class AdviseEfi < Question
    
    def ask
      wizard.title = "Boot Type"
      wizard.advise("\\nThis machine only has 4Kn type disks, so it will be configured for UEFI boot.", 8, 50)
    end

    def respond 
      task.set :boot_type, "efi"
    end

  end


  class AdviseMbr < Question
    
    def ask
      wizard.title = "Boot Type"
      @choice = wizard.advise("\\nThis machine does not support UEFI booting, so legacy MBR booting will be configured.", 8, 50)
    end

    def respond 
      task.set :boot_type, "mbr"
      subquestions.append AskEfiPartition.new(task)
    end

  end


  class AdviseError < Question
    
    def ask
      dialog.title = "Boot Type"
      dialog.alert("\\nThis machine does not support UEFI booting, But none of its disks seem to have 512K sectors that support legacy MBR Boot. This installer cannot work on this machine. Please see \\n\\nhttps://openzfs.github.io/openzfs-docs/Getting%20Started/Debian/index.html#root-on-zfs \\n\\nfor manual install instructions.", 14, 70)
      quit
    end

  end


  class AskEfiPartition < Question

    def ask
      wizard.title = "Create EFI Partition for future use?"
      items = [
        ["no", "Do not create EFI partition"],
        ["yes", "Create an un-used EFI partition in case it's needed in future"]
      ]
      height = 12
      width = 68
      menu_height = 2
      text = "\\nLegacy MBR Boot has been selected. Would you also like to create an unused EFI partition in case you need UEFI boot in future?"
      @choice = wizard.ask(text, items, height, width, menu_height)
    end

    def respond 
      task.set :efi_partition, @choice
    end

  end

  

end