require 'test'

class TestEncryption < Test

  def test_show_dialog
    mixed_disks do
      result = nil
      with_screen 46, 200 do
        with_dialog :menu, Proc.new{|*args| result = args; "ZFS"} do
          assert_not_quit do
            q = RootInstaller::Questions::Encryption.new(nil)
            q.ask
            assert_instance_of Question::Dialog, q.dialog
            assert_equal "Root Dataset Encryption", q.dialog.title
            assert_equal "YAROZI - Yet Another Root On ZFS installer", q.dialog.backtitle
            assert_nil   q.dialog.ok_label
            assert_equal fetch_or_save(result.to_s), result.to_s
            assert_equal "ZFS", q.root_encryption_type
          end
        end
      end  
    end  
  end

end
  