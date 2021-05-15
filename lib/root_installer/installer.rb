class RootInstaller::Installer < Task

  def initialize
    questions << ( @continue = RootInstaller::Questions::Continue.new(self) )
    questions << ( @disks = RootInstaller::Questions::DiskOverview.new(self) )
    questions << ( @disks = RootInstaller::Questions::BootType.new(self) )
    # questions << ( @disks = RootInstaller::Questions::Encryption.new(self) )
    # questions << ( @disks = RootInstaller::Questions::Swap.new(self) )
    # questions << ( @disks = RootInstaller::Questions::Partitions.new(self) )
    # questions << ( @disks = RootInstaller::Questions::InstallDetails.new(self) )
  end

  def perform
    #p Disk.all
  end



end

