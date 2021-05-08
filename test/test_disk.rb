require 'test'


class TestDisk < Test

  def test_string_list
    with_disk_sets do |set|
      assert_equal fetch_or_save(Disk.to_string_list, set), Disk.to_string_list
    end
  end

end
