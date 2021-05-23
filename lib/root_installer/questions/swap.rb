class RootInstaller::Questions::Swap < Question

  def text
    <<~EOF

      This installer can configure swap space for your machine.

      Because ZFS struggles when it does not have enough free RAM available, it's a bad idea to put swap on ZFS ZVOLs or in a swapfile on a ZFS dataset, so this installer uses separate non-ZFS swap partitions. This means that any data written to swap will NOT be checksummed. If you have ECC RAM and want to be sure that no non-checksummed data is used by your system, then it might be a good idea to not use swap and just buy more ECC RAM instead.

      Because your system's memory can contain secrets such as passwords and SSH keys that might be written to your swap device, it's important that swap is not in cleartext, which might allow an attacker who gained access to the swap device to recover secrets from it. This installer sets up swap on encrypted LUKS filesystems to prevent that.

      This installer can also set up swap on MDRAID volumes to provide redundancy and improve availability. This can be configured in a later screen.
 
    EOF
  end

  def ask
    wizard.title = "SWAP"
    wizard.yes_label = %{"Create encrypted LUKS swap"}
    wizard.no_label = %{"Do NOT create swap"}

    items = [
      ["none", "Do NOT create swap"],
      ["luks", "Create encrypted LUKS swap"]
    ]

    height = 30
    width = 76
    menu_height = 2
    
    @choice = wizard.menu(text, items, height, width, menu_height)
  end

  def respond
    task.set :configure_swap, @choice
  end


end