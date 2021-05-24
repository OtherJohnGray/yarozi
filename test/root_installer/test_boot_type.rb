require 'test'


class TestAskEfi < Test

  def test_ask_efi_selected
    mixed_disks do
      with_screen 40, 200 do
        result = nil
        with_dialog :menu, Proc.new{|*args| result = args; "efi"} do
          q = RootInstaller::Questions::BootType::AskEfi.new(nil)
          q.ask
          assert_equal "Boot Type", q.wizard.title
          assert_equal "YAROZI - Yet Another Root On ZFS installer", q.wizard.backtitle
          assert_equal fetch_or_save(result.to_s), result.to_s
          assert_equal "efi", q.instance_variable_get(:@choice)
        end
      end
    end
  end

  def test_respond
    q = RootInstaller::Questions::BootType::AskEfi.new(Task.new)
    q.instance_variable_set :@choice, "efi"
    q.respond
    assert_equal "efi", q.task.boot_type
    assert_equal 0, q.subquestions.length
  end

  def test_ask_mbr_selected
    mixed_disks do
      with_screen 40, 200 do
        result = nil
        with_dialog :menu, Proc.new{|*args| result = args; "mbr"} do
          q = RootInstaller::Questions::BootType::AskEfi.new(nil)
          q.ask
          assert_equal "Boot Type", q.wizard.title
          assert_equal "YAROZI - Yet Another Root On ZFS installer", q.wizard.backtitle
          assert_equal fetch_or_save(result.to_s), result.to_s
          assert_equal "mbr", q.instance_variable_get(:@choice)
        end
      end
    end
  end
  
  def test_respond_mbr_selected
    q = RootInstaller::Questions::BootType::AskEfi.new(Task.new)
    q.instance_variable_set :@choice, "mbr"
    q.respond
    assert_equal "mbr", q.task.boot_type
    assert_equal 1, q.subquestions.length
    assert_instance_of RootInstaller::Questions::BootType::AskEfiPartition, q.subquestions.first
  end

end


class TestAdviseEfi < Test

  def test_ask_efi_advised
    mixed_disks do
      with_screen 40, 200 do
        result = nil
        with_dialog :menu, Proc.new{|*args| result = args} do
          q = RootInstaller::Questions::BootType::AdviseEfi.new(nil)
          q.ask
          assert_equal "Boot Type", q.wizard.title
          assert_equal "YAROZI - Yet Another Root On ZFS installer", q.wizard.backtitle
          assert_equal fetch_or_save(result.to_s), result.to_s
        end
      end
    end
  end

  def test_respond
    q = RootInstaller::Questions::BootType::AdviseEfi.new(Task.new)
    q.respond
    assert_equal "efi", q.task.boot_type
    assert_equal 0, q.subquestions.length
  end

end


class TestAdviseMbr < Test

  def test_ask_efi_advised
    mixed_disks do
      with_screen 40, 200 do
        result = nil
        with_dialog :menu, Proc.new{|*args| result = args} do
          q = RootInstaller::Questions::BootType::AdviseEfi.new(nil)
          q.ask
          assert_equal "Boot Type", q.wizard.title
          assert_equal "YAROZI - Yet Another Root On ZFS installer", q.wizard.backtitle
          assert_equal fetch_or_save(result.to_s), result.to_s
        end
      end
    end
  end

  def test_respond
    q = RootInstaller::Questions::BootType::AdviseEfi.new(Task.new)
    q.respond
    assert_equal "efi", q.task.boot_type
    assert_equal 0, q.subquestions.length
  end

end



class TestBootType < Test

  def test_efi_512
    mixed_disks do
      q = RootInstaller::Questions::BootType.new(nil)
      q.stub(:efi_support?, true) do
        q.ask
        assert_equal 1, q.subquestions.length
        assert_instance_of RootInstaller::Questions::BootType::AskEfi, q.subquestions.first
      end
    end
  end

  def test_efi_4k
    largesector_disks do
      q = RootInstaller::Questions::BootType.new(nil)
      q.stub(:efi_support?, true) do
        q.ask
        assert_equal 1, q.subquestions.length
        assert_instance_of RootInstaller::Questions::BootType::AdviseEfi, q.subquestions.first
      end
    end
  end

  def test_legacy_512
    mixed_disks do
      q = RootInstaller::Questions::BootType.new(nil)
      q.stub(:efi_support?, false) do
        q.ask
        assert_equal 1, q.subquestions.length
        assert_instance_of RootInstaller::Questions::BootType::AdviseMbr, q.subquestions.first
      end
    end
  end

  def test_legacy_4k
    largesector_disks do
      q = RootInstaller::Questions::BootType.new(nil)
      q.stub(:efi_support?, false) do
        q.ask
        assert_equal 1, q.subquestions.length
        assert_instance_of RootInstaller::Questions::BootType::AdviseError, q.subquestions.first
      end
    end
  end

end



  # def test_ask_mbr_selected
  #   mixed_disks do
  #     with_screen 40, 200 do
  #       result = nil
  #       with_dialog :yesno, Proc.new{|*args| result = args; "mbr"} do
  #         q = RootInstaller::Questions::BootType::AskEfi.new(nil)
  #         q.ask
  #         assert_equal "Boot Type", q.wizard.title
  #         assert_equal "YAROZI - Yet Another Root On ZFS installer", q.wizard.backtitle
  #         assert_equal fetch_or_save(result.to_s), result.to_s
  #         assert_equal "efi", q.instance_variable_get(:@choice)
  #         assert_equal 0, q.subquestions.length
  #       end
  #     end
  #   end
  # end



  # def test_efi_512_mbr_chosen_and_efi_partition_chosen
  #   mixed_disks do
  #     with_screen 40, 200 do
  #       answers = [true, false]
  #       result = []
  #       task = Task.new
  #       with_dialog :yesno, Proc.new{|*args| result << args; answers.pop} do
  #         q = RootInstaller::Questions::BootType.new(task)
  #         q.stub(:efi_support?, true) do
  #           q.ask
  #           # check wizard
  #           assert_instance_of Dialog, q.wizard
  #           assert_equal "Boot Type", q.wizard.title
  #           assert_equal "YAROZI - Yet Another Root On ZFS installer", q.wizard.backtitle
  #           assert_equal "EFI\\ Boot", q.wizard.yes_label
  #           assert_equal "Legacy\\ MBR\\ Boot", q.wizard.no_label
  #           assert_equal fetch_or_save(result.to_s), result.to_s
  #           assert_equal :mbr, task.boot_type
  #           # check efi_partition_dialog
  #           assert_instance_of Dialog, q.efi_partition_dialog
  #           assert_equal "Create EFI Partition for future use?", q.efi_partition_dialog.title
  #           assert_equal "YAROZI - Yet Another Root On ZFS installer", q.efi_partition_dialog.backtitle
  #           assert_nil q.efi_partition_dialog.yes_label
  #           assert_nil q.efi_partition_dialog.no_label
  #           assert_equal fetch_or_save(result.to_s), result.to_s
  #           assert task.efi_partition
  #         end
  #       end
  #     end  
  #   end
  # end


  # def test_efi_512_mbr_chosen_and_efi_partition_not_chosen
  #   mixed_disks do
  #     with_screen 40, 200 do
  #       answers = [false, false]
  #       result = []
  #       task = Task.new
  #       with_dialog :yesno, Proc.new{|*args| result << args; answers.pop} do
  #         q = RootInstaller::Questions::BootType.new(task)
  #         q.stub(:efi_support?, true) do
  #           q.ask
  #           # check wizard
  #           assert_instance_of Dialog, q.wizard
  #           assert_equal "Boot Type", q.wizard.title
  #           assert_equal "YAROZI - Yet Another Root On ZFS installer", q.wizard.backtitle
  #           assert_equal "EFI\\ Boot", q.wizard.yes_label
  #           assert_equal "Legacy\\ MBR\\ Boot", q.wizard.no_label
  #           assert_equal fetch_or_save(result.to_s), result.to_s
  #           assert_equal :mbr, task.boot_type
  #           # check efi_partition_dialog
  #           assert_instance_of Dialog, q.efi_partition_dialog
  #           assert_equal "Create EFI Partition for future use?", q.efi_partition_dialog.title
  #           assert_equal "YAROZI - Yet Another Root On ZFS installer", q.efi_partition_dialog.backtitle
  #           assert_nil q.efi_partition_dialog.yes_label
  #           assert_nil q.efi_partition_dialog.no_label
  #           assert_equal fetch_or_save(result.to_s), result.to_s
  #           assert !task.efi_partition
  #         end
  #       end
  #     end  
  #   end
  # end


  # def test_efi_4k
  #   largesector_disks do
  #     result = nil
  #     task = Task.new
  #     with_screen 40, 200 do
  #       with_dialog :msgbox, Proc.new{|*args| result = args} do
  #         q = RootInstaller::Questions::BootType.new(task)
  #         q.stub(:efi_support?, true) do
  #           q.ask
  #           assert_instance_of Dialog, q.efi_advisory_dialog
  #           assert_equal "Boot Type", q.efi_advisory_dialog.title
  #           assert_equal "YAROZI - Yet Another Root On ZFS installer", q.efi_advisory_dialog.backtitle
  #           assert_nil   q.efi_advisory_dialog.ok_label
  #           assert_equal fetch_or_save(result.to_s), result.to_s
  #           assert_equal :efi, task.boot_type
  #         end
  #       end
  #     end  
  #   end
  # end


  # # ask_legacy tests

  # def test_not_efi_512_efi_partition_chosen
  #   mixed_disks do
  #     with_screen 40, 200 do
  #       result = []
  #       task = Task.new
  #       with_dialog :msgbox, Proc.new{|*args| result << args} do
  #         with_dialog :yesno, Proc.new{|*args| result << args} do
  #           q = RootInstaller::Questions::BootType.new(task)
  #           q.stub(:efi_support?, false) do
  #             q.ask
  #             # check wizard
  #             assert_instance_of Dialog, q.mbr_advisory_dialog
  #             assert_equal "Boot Type", q.mbr_advisory_dialog.title
  #             assert_equal "YAROZI - Yet Another Root On ZFS installer", q.mbr_advisory_dialog.backtitle
  #             assert_nil   q.mbr_advisory_dialog.ok_label
  #             assert_equal fetch_or_save(result.to_s), result.to_s
  #             assert_equal :mbr, task.boot_type
  #             # check efi_partition_dialog
  #             assert_instance_of Dialog, q.efi_partition_dialog
  #             assert_equal "Create EFI Partition for future use?", q.efi_partition_dialog.title
  #             assert_equal "YAROZI - Yet Another Root On ZFS installer", q.efi_partition_dialog.backtitle
  #             assert_nil q.efi_partition_dialog.yes_label
  #             assert_nil q.efi_partition_dialog.no_label
  #             assert_equal fetch_or_save(result.to_s), result.to_s
  #             assert task.efi_partition
  #           end
  #         end
  #       end
  #     end  
  #   end
  # end


  # def test_not_efi_512_efi_partition_not_chosen
  #   mixed_disks do
  #     with_screen 40, 200 do
  #       result = []
  #       task = Task.new
  #       with_dialog :msgbox, Proc.new{|*args| result << args} do
  #         with_dialog :yesno, Proc.new{|*args| result << args; false} do
  #           q = RootInstaller::Questions::BootType.new(task)
  #           q.stub(:efi_support?, false) do
  #             q.ask
  #             # check wizard
  #             assert_instance_of Dialog, q.mbr_advisory_dialog
  #             assert_equal "Boot Type", q.mbr_advisory_dialog.title
  #             assert_equal "YAROZI - Yet Another Root On ZFS installer", q.mbr_advisory_dialog.backtitle
  #             assert_nil   q.mbr_advisory_dialog.ok_label
  #             assert_equal fetch_or_save(result.to_s), result.to_s
  #             assert_equal :mbr, task.boot_type
  #             # check efi_partition_dialog
  #             assert_instance_of Dialog, q.efi_partition_dialog
  #             assert_equal "Create EFI Partition for future use?", q.efi_partition_dialog.title
  #             assert_equal "YAROZI - Yet Another Root On ZFS installer", q.efi_partition_dialog.backtitle
  #             assert_nil q.efi_partition_dialog.yes_label
  #             assert_nil q.efi_partition_dialog.no_label
  #             assert_equal fetch_or_save(result.to_s), result.to_s
  #             assert !task.efi_partition
  #           end
  #         end
  #       end
  #     end  
  #   end
  # end


  # def test_not_efi_4k
  #   largesector_disks do
  #     result = nil
  #     quits = nil
  #     task = Task.new
  #     with_screen 40, 200 do
  #       with_dialog :msgbox, Proc.new{|*args| result = args} do
  #         q = RootInstaller::Questions::BootType.new(task)
  #         q.stub(:efi_support?, false) do
  #           q.stub :quit, Proc.new{ quits = 1 } do
  #             q.ask
  #             assert_equal 1, quits
  #             assert_instance_of Dialog, q.mbr_error_dialog
  #             assert_equal "Boot Type", q.mbr_error_dialog.title
  #             assert_equal "YAROZI - Yet Another Root On ZFS installer", q.mbr_error_dialog.backtitle
  #             assert_nil   q.mbr_error_dialog.ok_label
  #             refute_respond_to task, :boot_type
  #             assert_equal fetch_or_save(result.to_s), result.to_s
  #           end
  #         end
  #       end
  #     end  
  #   end
  # end

