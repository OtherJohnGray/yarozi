require 'test'


class TestQuestion < Test
  
  def get_dialog
    dialog = Question.new(nil).dialog
  end


  def test_proxy_class
    assert get_dialog.class == Question::Dialog
  end


  def test_msgbox
    with_msgbox do
      d = get_dialog
      d.title = "Introduction and Disk Overview"
      d.backtitle = "YAROZI - Yet Another Root On ZFS installer"
      d.ok_label = "continue\\ and\\ select\\ disks"

      assert_equal d.title, "Introduction and Disk Overview"
      assert_equal d.backtitle, "YAROZI - Yet Another Root On ZFS installer"
      assert_equal d.ok_label, "continue\\ and\\ select\\ disks"
      assert_equal d.msgbox("this is a test dialog",50,150), ["this is a test dialog", 50, 150]
    end
  end

  def test_sizing
    with_msgbox do
      with_screen(24,80) do
        d = get_dialog
        assert_equal d.msgbox("this is a test dialog",50,150), ["this is a test dialog", 19, 70]
      end
      with_screen(60,200) do
        d = get_dialog
        assert_equal d.msgbox("this is a test dialog",50,150), ["this is a test dialog", 50, 150]
      end
    end
  end


end
