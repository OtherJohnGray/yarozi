class RootInstaller::Questions::Continue < Question

  attr_reader :answer

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
    dialog = MRDialog.new
    dialog.logger = Logger.new("./log/mrdialog.log")
    dialog.clear = true
    dialog.title = "***************** W A R N I N G ! ! ! *****************"
    dialog.backtitle = "YAROZI - Yet Another Root On ZFS installer"
    exit 1 unless dialog.yesno(text,18,80)
  end


end