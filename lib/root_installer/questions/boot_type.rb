class RootInstaller::Questions::BootType < Question

  attr_reader :boot_type, :efi_partition

  def ask
    File.directory?("/sys/firmware/efi") ? ask_efi : ask_legacy
  end

  def ask_efi
    if has_512k
      new_dialog.tap do |d|
        d.title = "Boot Type"
        d.yes_label = "EFI\\ Boot"
        d.no_label = "Legacy\\ MBR\\ Boot"
        if d.yesno("\\nThis machine supports both EFI and legacy MBR booting. What boot type would you like?", 8, 50)
          @boot_type = :efi
        else
          @boot_type = :mbr
          ask_efi_partition
        end
      end
    else
      new_dialog.tap do |d|
        d.title = "Boot Pool - select disks"
        d.msgbox("\\nThis machine only has 4Kn type disks, so it will be configured for UEFI boot.", 8, 50)
      end
      @boot_type = :efi
    end
  end

  def ask_legacy
    new_dialog.tap do |d|
      d.title = "Boot Type"
      d.msgbox("\\nThis machine does not support UEFI booting, so legacy MBR booting will be configured.", 8, 50)
    end
    ask_efi_partition
  end

  def ask_efi_partition
    new_dialog.tap do |d|
      d.title = "Create EFI Partition for future use?"
      @efi_partition = d.yesno("\\nLegacy MBR Boot has been selected. Would you also like to create an unused EFI partition in case you need UEFI boot in future?", 9, 50)
    end
  end


  def has_512k
    Disk.all.any? {|d| d.sector_size == 512}
  end


end