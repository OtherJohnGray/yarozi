class RootInstaller::Questions::PartitionsChecklist < Question



    def ask
      wizard.title = "Partitions"
      wizard.default_item = task.root_encryption_type if task.respond_to? :root_encryption_type
      text = <<~TEXT
        partition checklist....
      TEXT

      items = [
        ["None", "Do not encrypt root dataset"],
        ["ZFS", "Encrypt root dataset with ZFS native encryption"],
        ["LUKS", "Encrypt root dataset with LUKS"]
      ]

      height = 34
      width = 76
      menu_height = 3
      
      @choice = wizard.ask(text, items, height, width, menu_height)
    end


    def respond
      task.set :root_encryption_type, @choice
    end




end