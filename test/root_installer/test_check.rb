require 'test'

class TestCheck < Test
  
  def test_512k
    mixed_disks do
      check = RootInstaller::Questions::Check.new(nil)
      check.stub :efi_support?, Proc.new{ false } do
        check.stub :quit, Proc.new{ @quit = 1 } do
          check.ask
          assert_nil check.instance_variable_get(:@quit)
        end
      end
    end
  end

  def test_efi
    largesector_disks do
      check = RootInstaller::Questions::Check.new(nil)
      check.stub :efi_support?, Proc.new{ true } do
        check.stub :quit, Proc.new{ @quit = 1 } do
          check.ask
          assert_nil check.instance_variable_get(:@quit)
        end
      end
    end
  end

  def test_exit
    result = nil
    quits = nil
    largesector_disks do
      with_dialog :msgbox, Proc.new{|*args| result = args} do
        check = RootInstaller::Questions::Check.new(nil)
        check.stub :efi_support?, Proc.new{ false } do
          check.stub :quit, Proc.new{ quits = 1 } do
            check.ask
            assert_equal 1, quits
            assert_equal fetch_or_save(result.to_s), result.to_s
          end
        end
      end
    end
  end

end