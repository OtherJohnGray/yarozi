require 'test'

class TestBootType < Test
  
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
              assert_equal fetch_or_save(result.to_s), result.to_s
            end
          end
        end
      end  
    end
  end


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