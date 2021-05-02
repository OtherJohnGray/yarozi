require 'test'


class TestQuestion < Test
  

  def test_proxy_class
    assert Question.new(nil).dialog.class == Question::Dialog
  end


  def test_msgbox
    with_msgbox do
      dialog = Question.new(nil).dialog
      dialog.title = "Introduction and Disk Overview"
      dialog.backtitle = "YAROZI - Yet Another Root On ZFS installer"
      dialog.ok_label = "continue\\ and\\ select\\ disks"
      message = "this is a test dialog"

      assert_equal dialog.title, "Introduction and Disk Overview"
      assert_equal dialog.backtitle, "YAROZI - Yet Another Root On ZFS installer"
      assert_equal dialog.ok_label, "continue\\ and\\ select\\ disks"
      assert_equal dialog.msgbox(message,0,150), ["this is a test dialog", 44, 150]
    end
  end


end
