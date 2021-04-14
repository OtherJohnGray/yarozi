require 'mrdialog'
require './lib/disk.rb'

class RootInstaller

  def initialize
    
  end


  def run
    show_warning
    Disk.all
  end


  def show_warning()
    text = <<~EOF


      This installer is intended to be run on a "new" machine to install an Ubuntu root filesystem on a ZFS pool, and to set up the machine to boot into it.

      IT MAY OVERWRITE ANY DATA OR BOOTLOADERS THAT EXIST ON THIS MACHINE!!!

      Please do not run this on a machine that has any existing data or operating systems that you want to keep.

      Do you wish to continue?

 
    EOF
    dialog = MRDialog.new
    dialog.logger = Logger.new("./log/mrdialog.log")
    dialog.clear = true
    dialog.title = "***************** W A R N I N G ! ! ! *****************"
    dialog.backtitle = "YAROZI - Yet Another Root On ZFS installer"

    exit 1 unless dialog.yesno(text,18,80)
  end

end

