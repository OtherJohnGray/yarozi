require 'test'


class TestDiskOverview < Test
  
  def test_dialog
    with_disk_sets do |set|
      overview = RootInstaller::Questions::DiskOverview.new(nil)
      result = nil
      with_screen 40, 200 do
        with_dialog :msgbox, Proc.new{|*args| result = args} do
          overview.ask
        end
      end
      assert_equal "Introduction and Disk Overview", overview.dialog.title
      assert_equal "YAROZI - Yet Another Root On ZFS installer", overview.dialog.backtitle
      assert_equal "continue\\ and\\ select\\ disks", overview.dialog.ok_label
      assert_equal fetch_or_save(result.to_s, set), result.to_s
    end
  end

end