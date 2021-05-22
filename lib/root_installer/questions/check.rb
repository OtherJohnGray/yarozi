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
    dialog.title = "ERROR - Install environment not booted via UEFI"
    dialog.yes_label = "continue\\ and\\ erase\\ data"
    dialog.no_label = "exit\\ without\\ changes"
    list.quit 1 unless dialog.yesno(text,18,80)
  end


end