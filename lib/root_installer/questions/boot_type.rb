class RootInstaller::Questions::BootType < Question

  attr_reader :boot_type, :efi_partition, :efi_choice_dialog, :efi_advisory_dialog, 
              :mbr_advisory_dialog, :mbr_error_dialog, :efi_partition_dialog

  def ask
    efi_support? ? ask_efi : ask_legacy
  end

  def efi_support?
    File.directory?("/sys/firmware/efi")
  end

  def ask_efi
    if has_512k
      @efi_choice_dialog = new_dialog
      @efi_choice_dialog.title = "Boot Type"
      @efi_choice_dialog.yes_label = "EFI\\ Boot"
      @efi_choice_dialog.no_label = "Legacy\\ MBR\\ Boot"
      if @efi_choice_dialog.yesno("\\nThis machine supports both EFI and legacy MBR booting. What boot type would you like?", 8, 50)
        @boot_type = :efi
      else
        @boot_type = :mbr
        ask_efi_partition
      end
    else
      @efi_advisory_dialog = new_dialog
      @efi_advisory_dialog.title = "Boot Type"
      @efi_advisory_dialog.msgbox("\\nThis machine only has 4Kn type disks, so it will be configured for UEFI boot.", 8, 50)
      @boot_type = :efi
    end
  end

  def ask_legacy
    if has_512k
      @mbr_advisory_dialog = new_dialog
      @mbr_advisory_dialog.title = "Boot Type"
      @mbr_advisory_dialog.msgbox("\\nThis machine does not support UEFI booting, so legacy MBR booting will be configured.", 8, 50)
      ask_efi_partition
    else
      @mbr_error_dialog = new_dialog
      @mbr_error_dialog.title = "Boot Type"
      @mbr_error_dialog.msgbox('This machine does not support UEFI booting, But none of its disks is reporting 512K sectors that support legacy MBR Boot. This installer cannot work on this machine. Please see https://openzfs.github.io/openzfs-docs/Getting%20Started/Debian/index.html#root-on-zfs for manual install instructions.', 10, 70)
      quit 1
    end
  end

  def ask_efi_partition
    @efi_partition_dialog = new_dialog
    @efi_partition_dialog.title = "Create EFI Partition for future use?"
    @efi_partition = @efi_partition_dialog.yesno("\\nLegacy MBR Boot has been selected. Would you also like to create an unused EFI partition in case you need UEFI boot in future?", 9, 50)
  end


  def has_512k
    Disk.all.any? {|d| d.sector_size == 512}
  end


end