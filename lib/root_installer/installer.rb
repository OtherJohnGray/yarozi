class RootInstaller::Installer < Task

  def initialize
    questions << ( @continue = RootInstaller::Questions::Continue.new(self) )
  end

  def perform
    Disk.all
  end



end

