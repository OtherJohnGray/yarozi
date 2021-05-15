class RootInstaller::Questions::Encryption < Question

    attr_reader :root_encryption_type

    def ask
      dialog.title = "Root Dataset Encryption"
      dialog.nocancel = true
      text = <<~TEXT
        This installer can set up encryption for your root dataset in three different ways.

        The first is no encryption - data will be stored on the root dataset in cleartext. Anyone who gains physical access to the disks (e.g. by stealing them) can access the data. You will need to manage your own encryption if you want to make secure offsite backups of your root pool. You will not need to enter a password at the console in order to boot your machine or after restarting it.

        The second is ZFS native encryption - data will be encrypted using AES-256-GCM, but metadata such as the name of the root pool and snapshot names will be in cleartext. You will be able to use \\"zfs send\\" to make encrypted incremental offsite backups of your root pool without the backup machine being able to read your data. You will need to enter a password at the console every time you boot your machine or restart it.
      
        The third is LUKS encryption of each individual disk partition that underlies your root pool. Both data and metadata are encrypted. You will only be able to \\"zfs send\\" unencrypted snapshots, and will need to manage your own encryption if you want to make secure offsite backups of your root pool. You will need to enter a password at the console every time you boot your machine or restart it.

        Please select encryption type for the root dataset:
      TEXT

      items = [
        ["None", "root dataset will not be encrypted"],
        ["ZFS", "root dataset will be encrypted with ZFS native encryption"],
        ["LUKS", "root dataset partitions will be encrypted with LUKS"]
      ]

      height = 34
      width = 76
      menu_height = 3
      
      @root_encryption_type = dialog.menu(text, items, height, width, menu_height)
    end




end