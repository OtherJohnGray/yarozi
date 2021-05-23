require 'test'


class TestContinue < Test
  
  def test_continue_text
    continue = RootInstaller::Questions::Continue.new(nil)
    result = nil
    with_screen 40, 200 do
      with_dialog :yesno, Proc.new{|*args| result = args} do
        continue.ask
      end
    end
    assert_equal fetch_or_save(result.to_s), result.to_s
    assert_equal "WARNING", continue.dialog.title
    assert_equal "YAROZI - Yet Another Root On ZFS installer", continue.dialog.backtitle
    assert_equal "continue\\ and\\ erase\\ data", continue.dialog.yes_label
    assert_equal "exit\\ without\\ changes", continue.dialog.no_label
  end

  def test_continue_no
    quits = nil
    with_dialog :yesno, false do
      q = RootInstaller::Questions::Continue.new(nil)
      q.stub :quit, Proc.new{ quits = 1 } do
        q.ask
        assert_equal 1, quits
      end
    end
  end

  def test_continue_yes
    quits = nil
    with_dialog :yesno, true do
      q = RootInstaller::Questions::Continue.new(nil)
      q.stub :quit, Proc.new{ quits = 1 } do
        q.ask
        assert_nil quits
      end
    end
  end



end