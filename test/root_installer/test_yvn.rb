require 'test'

class TestSwap < Test

  def test_ask
    mixed_disks do
      result = nil
      with_screen 46, 200 do
        with_dialog :yesno, Proc.new{|*args| result = args} do
          q = RootInstaller::Questions::YVN.new(Task.new)
          q.task.define_singleton_method :configure_swap, Proc.new{true}
          q.ask
          assert_instance_of Dialog, q.wizard
          assert_equal "YAROZI VDEV Notation", q.wizard.title
          assert_equal "YAROZI - Yet Another Root On ZFS installer", q.wizard.backtitle
          assert_equal fetch_or_save(result.to_s), result.to_s
        end
      end  
    end  
  end

end
  