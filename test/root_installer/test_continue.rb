require 'test'


class TestQuestion < Test
  
  def test_continue_text
    result = nil
    with_screen 40, 200 do
      with_dialog :yesno, Proc.new{|*args| result = args} do
        RootInstaller::Questions::Continue.new(nil).ask
      end
    end
    compare_to_saved result.to_s
  end

  def test_continue_no
    with_dialog :yesno, false do
      assert_quit(1) do
        RootInstaller::Questions::Continue.new(nil).ask
      end
    end
  end

  def test_continue_yes
    with_dialog :yesno, true do
      assert_not_quit do
        RootInstaller::Questions::Continue.new(nil).ask
      end
    end
  end




end