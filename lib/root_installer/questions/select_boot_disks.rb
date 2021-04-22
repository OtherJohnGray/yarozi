class RootInstaller::Questions::SelectBootDisks < Question

  attr_reader :answer

  def text
    <<~EOF
    
      Please select all the disks that you would like to put boot pool partitions on. You will be able to configue them into VDEVs in the next step.

      The disks that you select will also have an EFI or legacy bios bootloader installed on them, depending on which option you choose.

    EOF
  end

  def ask
    dialog.title = "Boot Pool - select disks"
    dialog.backtitle = "YAROZI - Yet Another Root On ZFS installer"
    dialog.ok_label = "ok"
    message = text + Disk.to_string_list
    dialog.msgbox(message)
  end


end