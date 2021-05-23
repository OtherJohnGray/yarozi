class RootInstaller::Questions::Check < Question

  def text
    <<~EOF

      This machine has the disks shown below, which all have sector sizes larger than 512 bytes.

      This means that the installer must configure this machine for UEFI boot, since Legacy MBR boot is only supported on disks with 512 byte sectors.

      However, the environment from which you are running the installer was not booted via UEFI, so the installer cannot set up UEFI boot.

      Please restart this machine using UEFI boot and then run the installer again.

    EOF
  end

  def ask 
    unless has_512k? || efi_support?
      dialog = Dialog.new
      dialog.title = "ERROR - Install environment not booted via UEFI"
      dialog.ok_label = "exit\\ without\\ changes"
      dialog.msgbox(text + Disk.to_string_list,40,120)
      self.quit
    end
  end

  def quit
    exit 1
  end

  def clicked
    "next"
  end

  def respond
    # noop
  end

  def efi_support?
    File.directory?("/sys/firmware/efi")
  end

  def has_512k?
    Disk.all.any? {|d| d.sector_size == 512}
  end


end