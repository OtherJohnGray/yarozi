require 'test'


class TestDisk < Test


  def test_rescue_disks
    rescue_disks  do 
      compare_to_saved Disk.to_string_list
    end
  end


  def test_hpe_disks
    hpe_disks do
      compare_to_saved Disk.to_string_list
    end
  end


  def test_usb_disks
    usb_disks do
      compare_to_saved Disk.to_string_list
    end
  end




end
