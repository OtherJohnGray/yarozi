require 'test'

class TestQuestion < Test

  def test_class
    assert Question.new(nil).dialog.class == Dialog
  end


  def test_msgbox
    with_dialog :msgbox do
      with_screen 60, 200 do
        d = Question.new(nil).dialog
        d.title = "Introduction and Disk Overview"
        d.backtitle = "YAROZI - Yet Another Root On ZFS installer"
        d.ok_label = "continue\\ and\\ select\\ disks"

        assert_equal d.title, "Introduction and Disk Overview"
        assert_equal d.backtitle, "YAROZI - Yet Another Root On ZFS installer"
        assert_equal d.ok_label, "continue\\ and\\ select\\ disks"
        assert_equal d.msgbox("this is a test dialog",50,150), ["this is a test dialog", 50, 150]
      end
    end
  end

  def test_alert_sizing
    with_dialog :msgbox do
      with_screen 24, 80 do
        d = Question.new(nil).dialog
        assert_equal ["this is a test dialog", 19, 70], d.alert("this is a test dialog",50,150)
      end
      with_screen 60, 200 do
        d = Question.new(nil).dialog
        assert_equal ["this is a test dialog", 50, 150], d.alert("this is a test dialog",50,150)
      end
      with_screen 24, 80 do
        d = Question.new(nil).dialog
        assert_equal ["this is a test dialog", 16, 60], d.alert("this is a test dialog",0,0,8,20)
      end
      with_screen 24, 80 do
        d = Question.new(nil).dialog
        assert_equal ["this is a test dialog", 22, 75], d.alert("this is a test dialog",22,75,1,1)
      end
    end
  end

  def test_advise_sizing
    with_dialog :yesno do
      with_screen 24, 80 do
        d = Question.new(nil).dialog
        assert_equal ["this is a test dialog", 19, 70], d.advise("this is a test dialog",50,150)
      end
      with_screen 60, 200 do
        d = Question.new(nil).dialog
        assert_equal ["this is a test dialog", 50, 150], d.advise("this is a test dialog",50,150)
      end
      with_screen 24, 80 do
        d = Question.new(nil).dialog
        assert_equal ["this is a test dialog", 16, 60], d.advise("this is a test dialog",0,0,8,20)
      end
      with_screen 24, 80 do
        d = Question.new(nil).dialog
        assert_equal ["this is a test dialog", 22, 75], d.advise("this is a test dialog",22,75,1,1)
      end
    end
  end

  def test_ask_sizing
    with_dialog :menu do
      with_screen 24, 80 do
        d = Question.new(nil).dialog
        assert_equal ["this is a test dialog", ["a","b"], 19, 70, 2], d.ask("this is a test dialog", ["a","b"], 50, 150, 2 )
      end
      with_screen 60, 200 do
        d = Question.new(nil).dialog
        assert_equal ["this is a test dialog", ["a","b"], 50, 150, 2], d.ask("this is a test dialog", ["a","b"], 50, 150, 2 )
      end
      with_screen 24, 80 do
        d = Question.new(nil).dialog
        assert_equal ["this is a test dialog", ["a", "b"], 16, 60, 2], d.ask("this is a test dialog", ["a","b"], 0, 0, 2, 8, 20 )
      end
      with_screen 24, 80 do
        d = Question.new(nil).dialog
        assert_equal ["this is a test dialog", ["a", "b"], 22, 75, 2], d.ask("this is a test dialog", ["a","b"], 22, 75, 2, 1, 1 )
      end
    end
  end

  def test_reset
    q = Question.new
    q.subquestions.append Question.new
    q.reset
    assert_equal 0, q.subquestions.length
  end


end
