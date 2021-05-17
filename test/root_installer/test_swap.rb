require 'test'

class TestSwap < Test

  def test_yes
    mixed_disks do
      result = nil
      task = Task.new
      with_screen 46, 200 do
        with_dialog :yesno, Proc.new{|*args| result = args} do
          q = RootInstaller::Questions::Swap.new(task)
          q.ask
          assert_instance_of Question::Dialog, q.dialog
          assert_equal "SWAP", q.dialog.title
          assert_equal "YAROZI - Yet Another Root On ZFS installer", q.dialog.backtitle
          assert_equal %{"Create encrypted LUKS swap"}, q.dialog.yes_label
          assert_equal %{"Do NOT create swap"}, q.dialog.no_label
          assert_equal fetch_or_save(result.to_s), result.to_s
          assert task.configure_swap
        end
      end  
    end  
  end

  def test_no
    mixed_disks do
      result = nil
      task = Task.new
      with_screen 46, 200 do
        with_dialog :yesno, Proc.new{|*args| result = args; false} do
          q = RootInstaller::Questions::Swap.new(task)
          q.ask
          assert_instance_of Question::Dialog, q.dialog
          assert_equal "SWAP", q.dialog.title
          assert_equal "YAROZI - Yet Another Root On ZFS installer", q.dialog.backtitle
          assert_equal %{"Create encrypted LUKS swap"}, q.dialog.yes_label
          assert_equal %{"Do NOT create swap"}, q.dialog.no_label
          assert_equal fetch_or_save(result.to_s), result.to_s
          assert !task.configure_swap
        end
      end  
    end  
  end

end
  