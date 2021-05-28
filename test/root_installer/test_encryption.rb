require 'test'

class TestEncryption < Test

  def test_ask
    mixed_disks do
      result = nil
      task = Task.new
      with_screen 46, 200 do
        with_dialog :menu, Proc.new{|*args| result = args; "ZFS"} do
          q = RootInstaller::Questions::Encryption.new(task)
          q.ask
          assert_instance_of Dialog, q.wizard
          assert_equal "Root Dataset Encryption", q.wizard.title
          assert_equal "YAROZI - Yet Another Root On ZFS installer", q.wizard.backtitle
          assert_equal fetch_or_save(result.to_s), result.to_s
          assert_equal "ZFS", q.instance_variable_get(:@choice)
        end
      end  
    end  
  end

  def test_respond
    mixed_disks do
      result = nil
      task = Task.new
      q = RootInstaller::Questions::Encryption.new(task)
      q.instance_variable_set :@choice, "ZFS"
      q.respond
      assert_equal "ZFS", task.root_encryption_type
    end  
  end

  def test_ask_default_item
    q = RootInstaller::Questions::Encryption.new(Task.new)
    q.task.define_singleton_method :root_encryption_type, Proc.new{"ZFS"}
    with_dialog :menu  do
      q.ask
    end
    assert_equal "ZFS", q.wizard.default_item
  end


end
  