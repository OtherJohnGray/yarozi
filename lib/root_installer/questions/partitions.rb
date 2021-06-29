class RootInstaller::Questions::Partitions < Question

    def ask
      loop do
        wizard.title = "Disk Partitions"
        wizard.default_item = @partitions_type if @partitions_type
        text = <<~TEXT

          You can specify on which disks the installer should place your 
          boot pool, root pool, and swap partitions in two different ways.

          The first is to select the drives from a list. This is good for simple setups, e.g. a single drive, a mirror or striped mirror, or a single small RAIDZ VDEV. 

          The second way is using Yarozi VDEV Notation (tm?), which is a Simple Syntax for Complex Configuration. If you choose this option, The YVN manual will be shown on the next screen.

          How yould you like to choose the disks for your pools?
        TEXT

        items = [
          ["checkbox", "Select drives from a list"],
          ["yvn", "Use Yarozi VDEV Notation"],
        ]

        height = 21
        width = 76
        menu_height = 2
        
        @partitions_type = wizard.ask(text, items, height, width, menu_height)

        break if %w(yvn checkbox).include? @partitions_type
      end
    end


    def respond
      case @partitions_type
      when "yvn"
        subquestions.append RootInstaller::Questions::PartitionsYVN.new(task)
      else
        subquestions.append RootInstaller::Questions::PartitionsCheckbox.new(task)
      end
    end




end