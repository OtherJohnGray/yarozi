require 'test'


class TestDisk < Test

  def test_string_list
    all_disk_sets do |set|
      compare_to_saved Disk.to_string_list, set
    end
  end

end
