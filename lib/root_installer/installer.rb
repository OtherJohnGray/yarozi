class RootInstaller::Installer < Task

  def initialize
    questions.append RootInstaller::Questions::Check.new(self)
    questions.append RootInstaller::Questions::Continue.new(self)
    # questions.append RootInstaller::Questions::DiskOverview.new(self)
    # questions.append RootInstaller::Questions::BootType.new(self)
    # questions.append RootInstaller::Questions::Encryption.new(self)
    # questions.append RootInstaller::Questions::Swap.new(self)
    # questions.append RootInstaller::Questions::Compression.new(self)
    # questions.append RootInstaller::Questions::Partitions.new(self)
    # questions.append RootInstaller::Questions::InstallDetails.new(self)
  end

  def perform
    #p Disk.all
  end



end

