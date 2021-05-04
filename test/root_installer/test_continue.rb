require 'test'


class TestQuestion < Test
  
  def test_continue_text
    continue = RootInstaller::Questions::Continue.new(nil)
    result = nil
    with_screen 40, 200 do
      with_dialog :yesno, Proc.new{|*args| result = args} do
        continue.ask
      end
    end
    compare_to_saved result.to_s
    d = continue.dialog
    assert_equal "WARNING", d.title
    assert_equal "YAROZI - Yet Another Root On ZFS installer", d.backtitle
    assert_equal "continue\\ and\\ erase\\ data", d.yes_label
    assert_equal "exit\\ without\\ changes", d.no_label
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