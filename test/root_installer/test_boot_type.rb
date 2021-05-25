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

  def test_ask_mbr_advised
    mixed_disks do
      with_screen 40, 200 do
        result = nil
        with_dialog :menu, Proc.new{|*args| result = args} do
          q = RootInstaller::Questions::BootType::AdviseMbr.new(nil)
          q.ask
          assert_equal "Boot Type", q.wizard.title
          assert_equal "YAROZI - Yet Another Root On ZFS installer", q.wizard.backtitle
          assert_equal fetch_or_save(result.to_s), result.to_s
        end
      end
    end
  end

  def test_respond
    q = RootInstaller::Questions::BootType::AdviseMbr.new(Task.new)
    q.respond
    assert_equal "mbr", q.task.boot_type
    assert_equal 1, q.subquestions.length
    assert_instance_of RootInstaller::Questions::BootType::AskEfiPartition, q.subquestions.first
  end

end


class TestAdviseError < Test

  def test_ask_error_advised
    mixed_disks do
      with_screen 40, 200 do
        result = nil
        with_dialog :msgbox, Proc.new{|*args| result = args} do
          q = RootInstaller::Questions::BootType::AdviseError.new(nil)
          assert_equal 1, quit_code{q.ask}
          assert_equal "Boot Type", q.dialog.title
          assert_equal "YAROZI - Yet Another Root On ZFS installer", q.dialog.backtitle
          assert_equal fetch_or_save(result.to_s), result.to_s
        end
      end
    end
  end

end


class TestAskEfiPartition < Test

  def test_ask_efi_partition_selected
    mixed_disks do
      with_screen 40, 200 do
        result = nil
        with_dialog :menu, Proc.new{|*args| result = args; "yes"} do
          q = RootInstaller::Questions::BootType::AskEfiPartition.new(nil)
          q.ask
          assert_equal "Create EFI Partition for future use?", q.wizard.title
          assert_equal "YAROZI - Yet Another Root On ZFS installer", q.wizard.backtitle
          assert_equal fetch_or_save(result.to_s), result.to_s
          assert_equal "yes", q.instance_variable_get(:@choice)
        end
      end
    end
  end

  def test_respond_selected
    q = RootInstaller::Questions::BootType::AskEfi.new(Task.new)
    q.instance_variable_set :@choice, "yes"
    q.respond
    assert_equal "yes", q.task.boot_type
  end

  def test_ask_efi_partition_not_selected
    mixed_disks do
      with_screen 40, 200 do
        result = nil
        with_dialog :menu, Proc.new{|*args| result = args; "no"} do
          q = RootInstaller::Questions::BootType::AskEfiPartition.new(nil)
          q.ask
          assert_equal "Create EFI Partition for future use?", q.wizard.title
          assert_equal "YAROZI - Yet Another Root On ZFS installer", q.wizard.backtitle
          assert_equal fetch_or_save(result.to_s), result.to_s
          assert_equal "no", q.instance_variable_get(:@choice)
        end
      end
    end
  end

  def test_respond_not_selected
    q = RootInstaller::Questions::BootType::AskEfi.new(Task.new)
    q.instance_variable_set :@choice, "no"
    q.respond
    assert_equal "no", q.task.boot_type
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
