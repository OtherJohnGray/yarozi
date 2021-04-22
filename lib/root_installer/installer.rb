class RootInstaller::Installer < Task

  def initialize
    questions << ( @continue = RootInstaller::Questions::Continue.new(self) )
    questions << ( @disks = RootInstaller::Questions::DiskOverview.new(self) )
    questions << ( @disks = RootInstaller::Questions::SelectBootDisks.new(self) )
  end

  def perform
    #p Disk.all
  end



end

