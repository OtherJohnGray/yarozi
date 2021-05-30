require 'test'

class TestBoot < Test
  def test_ask_boot_with_efi
    mixed_disks do
      result = nil
      with_screen 46, 200 do
        # with_dialog :form, Proc.new{|*args| result = args} do
          q = RootInstaller::Questions::Partitions::Boot.new(Task.new)
          q.task.define_singleton_method :boot_type, Proc.new{"efi"}
          q.ask
          assert_instance_of Dialog, q.wizard
          assert_equal "Boot pool", q.wizard.title
          assert_equal "YAROZI - Yet Another Root On ZFS installer", q.wizard.backtitle
          assert_equal fetch_or_save(result.to_s), result.to_s
        # end
      end  
    end  
  end
end

class TestPartitiosn < Test

  def test_ask_yvn_with_swap
    mixed_disks do
      result = nil
      with_screen 46, 200 do
        with_dialog :yesno, Proc.new{|*args| result = args} do
          q = RootInstaller::Questions::Partitions.new(Task.new)
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

  def test_ask_yvn_without_swap
    mixed_disks do
      result = nil
      with_screen 46, 200 do
        with_dialog :yesno, Proc.new{|*args| result = args} do
          q = RootInstaller::Questions::Partitions.new(Task.new)
          q.task.define_singleton_method :configure_swap, Proc.new{false}
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
  