require 'test'

class TestBootType < Test
  
  # ask_efi tests

  def test_efi_512_efi_chosen
    mixed_disks do
      result = nil
      with_screen 40, 200 do
        with_dialog :yesno, Proc.new{|*args| result = args} do
          assert_not_quit do
            q = RootInstaller::Questions::BootType.new(nil)
            q.stub(:efi_support?, true) do
              q.ask
              assert_instance_of Question::Dialog, q.efi_choice_dialog
              assert_equal "Boot Type", q.efi_choice_dialog.title
              assert_equal "YAROZI - Yet Another Root On ZFS installer", q.efi_choice_dialog.backtitle
              assert_equal "EFI\\ Boot", q.efi_choice_dialog.yes_label
              assert_equal "Legacy\\ MBR\\ Boot", q.efi_choice_dialog.no_label
              assert_equal fetch_or_save(result.to_s), result.to_s
              assert_equal :efi, q.boot_type
            end
          end
        end
      end  
    end
  end


  def test_efi_512_mbr_chosen_and_efi_partition_chosen
    mixed_disks do
      with_screen 40, 200 do
        answers = [true, false]
        result = []
        with_dialog :yesno, Proc.new{|*args| result << args; answers.pop} do
          assert_not_quit do
            q = RootInstaller::Questions::BootType.new(nil)
            q.stub(:efi_support?, true) do
              q.ask
              # check efi_choice_dialog
              assert_instance_of Question::Dialog, q.efi_choice_dialog
              assert_equal "Boot Type", q.efi_choice_dialog.title
              assert_equal "YAROZI - Yet Another Root On ZFS installer", q.efi_choice_dialog.backtitle
              assert_equal "EFI\\ Boot", q.efi_choice_dialog.yes_label
              assert_equal "Legacy\\ MBR\\ Boot", q.efi_choice_dialog.no_label
              assert_equal fetch_or_save(result.to_s), result.to_s
              assert_equal :mbr, q.boot_type
              # check efi_partition_dialog
              assert_instance_of Question::Dialog, q.efi_partition_dialog
              assert_equal "Create EFI Partition for future use?", q.efi_partition_dialog.title
              assert_equal "YAROZI - Yet Another Root On ZFS installer", q.efi_partition_dialog.backtitle
              assert_nil q.efi_partition_dialog.yes_label
              assert_nil q.efi_partition_dialog.no_label
              assert_equal fetch_or_save(result.to_s), result.to_s
              assert q.efi_partition
            end
          end
        end
      end  
    end
  end


  def test_efi_512_mbr_chosen_and_efi_partition_not_chosen
    mixed_disks do
      with_screen 40, 200 do
        answers = [false, false]
        result = []
        with_dialog :yesno, Proc.new{|*args| result << args; answers.pop} do
          assert_not_quit do
            q = RootInstaller::Questions::BootType.new(nil)
            q.stub(:efi_support?, true) do
              q.ask
              # check efi_choice_dialog
              assert_instance_of Question::Dialog, q.efi_choice_dialog
              assert_equal "Boot Type", q.efi_choice_dialog.title
              assert_equal "YAROZI - Yet Another Root On ZFS installer", q.efi_choice_dialog.backtitle
              assert_equal "EFI\\ Boot", q.efi_choice_dialog.yes_label
              assert_equal "Legacy\\ MBR\\ Boot", q.efi_choice_dialog.no_label
              assert_equal fetch_or_save(result.to_s), result.to_s
              assert_equal :mbr, q.boot_type
              # check efi_partition_dialog
              assert_instance_of Question::Dialog, q.efi_partition_dialog
              assert_equal "Create EFI Partition for future use?", q.efi_partition_dialog.title
              assert_equal "YAROZI - Yet Another Root On ZFS installer", q.efi_partition_dialog.backtitle
              assert_nil q.efi_partition_dialog.yes_label
              assert_nil q.efi_partition_dialog.no_label
              assert_equal fetch_or_save(result.to_s), result.to_s
              assert !q.efi_partition
            end
          end
        end
      end  
    end
  end


  def test_efi_4k
    largesector_disks do
      result = nil
      with_screen 40, 200 do
        with_dialog :msgbox, Proc.new{|*args| result = args} do
          assert_not_quit do
            q = RootInstaller::Questions::BootType.new(nil)
            q.stub(:efi_support?, true) do
              q.ask
              assert_instance_of Question::Dialog, q.efi_advisory_dialog
              assert_equal "Boot Type", q.efi_advisory_dialog.title
              assert_equal "YAROZI - Yet Another Root On ZFS installer", q.efi_advisory_dialog.backtitle
              assert_nil   q.efi_advisory_dialog.ok_label
              assert_equal fetch_or_save(result.to_s), result.to_s
              assert_equal :efi, q.boot_type
            end
          end
        end
      end  
    end
  end


  # ask_legacy tests

  def test_not_efi_512_efi_partition_chosen
    mixed_disks do
      with_screen 40, 200 do
        result = []
        with_dialog :msgbox, Proc.new{|*args| result << args} do
          with_dialog :yesno, Proc.new{|*args| result << args} do
            assert_not_quit do
              q = RootInstaller::Questions::BootType.new(nil)
              q.stub(:efi_support?, false) do
                q.ask
                # check efi_choice_dialog
                assert_instance_of Question::Dialog, q.mbr_advisory_dialog
                assert_equal "Boot Type", q.mbr_advisory_dialog.title
                assert_equal "YAROZI - Yet Another Root On ZFS installer", q.mbr_advisory_dialog.backtitle
                assert_nil   q.mbr_advisory_dialog.ok_label
                assert_equal fetch_or_save(result.to_s), result.to_s
                assert_equal :mbr, q.boot_type
                # check efi_partition_dialog
                assert_instance_of Question::Dialog, q.efi_partition_dialog
                assert_equal "Create EFI Partition for future use?", q.efi_partition_dialog.title
                assert_equal "YAROZI - Yet Another Root On ZFS installer", q.efi_partition_dialog.backtitle
                assert_nil q.efi_partition_dialog.yes_label
                assert_nil q.efi_partition_dialog.no_label
                assert_equal fetch_or_save(result.to_s), result.to_s
                assert q.efi_partition
              end
            end
          end
        end
      end  
    end
  end


  def test_not_efi_512_efi_partition_not_chosen
    mixed_disks do
      with_screen 40, 200 do
        result = []
        with_dialog :msgbox, Proc.new{|*args| result << args} do
          with_dialog :yesno, Proc.new{|*args| result << args; false} do
            assert_not_quit do
              q = RootInstaller::Questions::BootType.new(nil)
              q.stub(:efi_support?, false) do
                q.ask
                # check efi_choice_dialog
                assert_instance_of Question::Dialog, q.mbr_advisory_dialog
                assert_equal "Boot Type", q.mbr_advisory_dialog.title
                assert_equal "YAROZI - Yet Another Root On ZFS installer", q.mbr_advisory_dialog.backtitle
                assert_nil   q.mbr_advisory_dialog.ok_label
                assert_equal fetch_or_save(result.to_s), result.to_s
                assert_equal :mbr, q.boot_type
                # check efi_partition_dialog
                assert_instance_of Question::Dialog, q.efi_partition_dialog
                assert_equal "Create EFI Partition for future use?", q.efi_partition_dialog.title
                assert_equal "YAROZI - Yet Another Root On ZFS installer", q.efi_partition_dialog.backtitle
                assert_nil q.efi_partition_dialog.yes_label
                assert_nil q.efi_partition_dialog.no_label
                assert_equal fetch_or_save(result.to_s), result.to_s
                assert !q.efi_partition
              end
            end
          end
        end
      end  
    end
  end


  def test_not_efi_4k
    largesector_disks do
      result = nil
      with_screen 40, 200 do
        with_dialog :msgbox, Proc.new{|*args| result = args} do
          q = RootInstaller::Questions::BootType.new(nil)
          assert_quit 1 do
            q.stub(:efi_support?, false) do
              q.ask
              assert_instance_of Question::Dialog, q.mbr_error_dialog
              assert_equal "Boot Type", q.mbr_error_dialog.title
              assert_equal "YAROZI - Yet Another Root On ZFS installer", q.mbr_error_dialog.backtitle
              assert_nil   q.mbr_error_dialog.ok_label
              assert_nil   q.boot_type
              assert_equal fetch_or_save(result.to_s), result.to_s
            end
          end
        end
      end  
    end
  end

  # catchall tests  

  def test_ok
    with_disk_sets do |set|
      with_dialog :yesno, true do
        with_dialog :msgbox, true do
          assert_not_quit do
              q = RootInstaller::Questions::BootType.new(nil)
              q.stub(:efi_support?, true ) do
                q.ask
              end
          end
        end
      end
    end
  end

end