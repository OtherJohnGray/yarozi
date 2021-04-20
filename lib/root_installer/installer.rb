class RootInstaller::Installer < Task

  def initialize
    questions << ( @continue = RootInstaller::Questions::Continue.new(self) )
    questions << ( @disks = RootInstaller::Questions::DiskOverview.new(self) )
  end

  def perform
    Disk.all
  end



end

