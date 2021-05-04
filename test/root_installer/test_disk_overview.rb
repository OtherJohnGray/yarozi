require 'test'


class TestDiskOverview < Test
  
  def test_rescue_disks
    rescue_disks do
      compare_to_saved check_dialog
    end
  end

  def test_hpe_disks
    hpe_disks do
      compare_to_saved check_dialog
    end
  end

  def test_usb_disks
    usb_disks do
      compare_to_saved check_dialog
    end
  end

  def check_dialog
    check_ok
    overview = RootInstaller::Questions::DiskOverview.new(nil)
    result = nil
    with_screen 40, 200 do
      with_dialog :msgbox, Proc.new{|*args| result = args} do
        overview.ask
      end
    end
    d = overview.dialog
    assert_equal "Introduction and Disk Overview", d.title
    assert_equal "YAROZI - Yet Another Root On ZFS installer", d.backtitle
    assert_equal "continue\\ and\\ select\\ disks", d.ok_label
    result.to_s
  end

  def check_ok
    with_dialog :msgbox, true do
      assert_not_quit do
        RootInstaller::Questions::DiskOverview.new(nil).ask
      end
    end
  end

end