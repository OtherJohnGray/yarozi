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

  def test_sizing
    with_dialog :msgbox do
      with_screen 24, 80 do
        d = Question.new(nil).dialog
        assert_equal ["this is a test dialog", 19, 70], d.msgbox("this is a test dialog",50,150)
      end
      with_screen 60, 200 do
        d = Question.new(nil).dialog
        assert_equal ["this is a test dialog", 50, 150], d.msgbox("this is a test dialog",50,150)
      end
      with_screen 24, 80 do
        d = Question.new(nil).dialog
        assert_equal ["this is a test dialog", 16, 60], d.msgbox("this is a test dialog",0,0,8,20)
      end
      with_screen 24, 80 do
        d = Question.new(nil).dialog
        assert_equal ["this is a test dialog", 22, 75], d.msgbox("this is a test dialog",22,75,1,1)
      end
    end
  end

  def test_reset
    q = Question.new
    q.subquestions.append Question.new
    q.reset
    assert_equal 0, q.subquestions.length
  end

  def test_clicked
    q = Question.new
    d = q.dialog
    d.instance_variable_set :@selected_button, "ok"
    assert_equal "back", q.clicked
    d.instance_variable_set :@selected_button, "extra"
    assert_equal "next", q.clicked
    d.instance_variable_set :@selected_button, "cancel"
    assert_equal "cancel", q.clicked
    d.instance_variable_set :@selected_button, "yes" 
    assert_equal "back", q.clicked
    d.instance_variable_set :@selected_button, "no"
    assert_equal "cancel", q.clicked
  end

end
