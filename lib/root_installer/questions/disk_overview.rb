class RootInstaller::Questions::DiskOverview < Question

  attr_reader :answer

  def text
    <<~EOF
      This installer creates a ZFS root installation using Mirror VDEVs. Two pools are created, a boot pool and a root pool. VDEVs are created on disk partitions, and you can specify which disks to create the partitions on, the number of partitions in each VDEV, and the number of VDEVs in each pool. The installer will also create encrypted swap on MDRAID on disk partitions if you wish to do so.

      The following is a list of the disks in your system. Please examine them and decide how you would like to configure the VDEVs for your pools and your swap partitions, before continuing to set up your disks:
    EOF
  end

  def ask
    dialog = MRDialog.new
    dialog.logger = Logger.new("./log/mrdialog.log")
    dialog.clear = true
    dialog.title = "***************** W A R N I N G ! ! ! *****************"
    dialog.backtitle = "YAROZI - Yet Another Root On ZFS installer"
    exit 1 unless dialog.yesno(text,24,80)
  end


end