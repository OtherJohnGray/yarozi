require 'test'


class TestDiskOverview < Test
  
  def test_dialog
    all_disk_sets do |set|
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
      compare_to_saved result.to_s, "_with_#{set}_disks"
    end
  end

  def test_ok
    all_disk_sets do |set|
      with_dialog :msgbox, true do
        assert_not_quit do
          RootInstaller::Questions::DiskOverview.new(nil).ask
        end
      end
    end
  end

end