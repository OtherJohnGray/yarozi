class RootInstaller::Questions::Continue < Question

  def text
    <<~EOF

      ************************** W A R N I N G ! ! ! **************************

      This installer is intended to create a Debian ZFS root filesystem on an EMPTY machine.

      IT MAY OVERWRITE ANY DATA OR BOOTLOADERS THAT EXIST ON THIS MACHINE!!!

      Please do not run this on a machine that has any existing data or operating systems that you want to keep.

      Do you wish to continue?

      ************************** W A R N I N G ! ! ! **************************
 
    EOF
  end

  def ask
    dialog.title = "WARNING"
    dialog.yes_label = "continue\\ and\\ erase\\ data"
    dialog.no_label = "exit\\ without\\ changes"
    quit unless dialog.advise(text,18,80)
  end

end