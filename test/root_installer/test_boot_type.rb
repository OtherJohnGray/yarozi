require 'test'


class TestBootType < Test
  
  def test_efi_4k
    largesector_disks do
      result = nil
      with_screen 40, 200 do
        with_dialog :msgbox do
          RootInstaller::Questions::BootType.stub(:efi_support?, true ) do
            q = RootInstaller::Questions::BootType.new(nil)
            q.ask
            assert_instance_of Question::Dialog, q.efi_advisory_dialog
            assert_equal "Boot Type", q.efi_advisory_dialog.title
            assert_equal "YAROZI - Yet Another Root On ZFS installer", q.efi_advisory_dialog.backtitle
            assert_equal nil, q.efi_advisory_dialog.ok_label
            assert_equal fetch_or_save(result.to_s), result.to_s
          end
        end
      end  
    end
  end
asdf


  # def test_dialog
  #   with_disk_sets do |set|
  #     overview = RootInstaller::Questions::BootType.new(nil)
  #     result = nil
  #     with_screen 40, 200 do
  #       with_dialog :msgbox, Proc.new{|*args| result = args} do
  #         overview.ask
  #       end
  #     end
  #     assert_equal "Introduction and Disk Overview", overview.dialog.title
  #     assert_equal "YAROZI - Yet Another Root On ZFS installer", overview.dialog.backtitle
  #     assert_equal "continue\\ and\\ select\\ disks", overview.dialog.ok_label
  #     assert_equal fetch_or_save(result.to_s, set), result.to_s
  #   end
  # end

  def test_ok
    with_disk_sets do |set|
      with_dialog :yesno, true do
        assert_not_quit do
          RootInstaller::Questions::BootType.new(nil).ask
        end
      end
    end
  end

end