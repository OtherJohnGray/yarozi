require 'test'

class TestSwap < Test

  def test_ask
    mixed_disks do
      result = nil
      task = Task.new
      with_screen 46, 200 do
        with_dialog :menu, Proc.new{|*args| result = args; "none"} do
          q = RootInstaller::Questions::Swap.new(task)
          q.ask
          assert_instance_of Dialog, q.wizard
          assert_equal "SWAP", q.wizard.title
          assert_equal "YAROZI - Yet Another Root On ZFS installer", q.wizard.backtitle
          assert_equal fetch_or_save(result.to_s), result.to_s
          assert_equal "none", q.instance_variable_get(:@choice)
        end
      end  
    end  
  end

  def test_respond
    q = RootInstaller::Questions::Swap.new(Task.new)
    q.instance_variable_set :@choice, "none"
    q.respond
    assert_equal "none", q.task.configure_swap
    assert_equal 0, q.subquestions.length
  end

end
  