require 'test'

class TestCheck < Test
  
  def test_512k
    mixed_disks do
      q = RootInstaller::Questions::Check.new(nil)
      q.stub :efi_support?, Proc.new{ false } do
        assert_nil quit_code{q.ask}
        assert_respond_to q, :respond
      end
    end
  end

  def test_efi
    largesector_disks do
      q = RootInstaller::Questions::Check.new(nil)
      q.stub :efi_support?, Proc.new{ true } do
        assert_nil quit_code{q.ask}
        assert_respond_to q, :respond
      end
    end
  end

  def test_exit
    result = nil
    quits = nil
    largesector_disks do
      with_screen 40, 200 do
        with_dialog :msgbox, Proc.new{|*args| result = args} do
          q = RootInstaller::Questions::Check.new(nil)
          q.stub :efi_support?, Proc.new{ false } do
            assert_equal 1, quit_code{q.ask}
            assert_equal "ERROR - Install environment not booted via UEFI", q.dialog.title
            assert_equal "YAROZI - Yet Another Root On ZFS installer", q.dialog.backtitle
            assert_equal "exit\\ without\\ changes", q.dialog.ok_label
            assert_equal fetch_or_save(result.to_s), result.to_s
          end
        end
      end
    end
  end

end