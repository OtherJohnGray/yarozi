require 'test'
require 'disk'

# class Disk

#   def rotation
#     /^ata/ =~ id
#   end

# end


class DiskTest < Test
  

  def test_rescue_disks
    rescue_disks  do 
     # IO.write("test/data/rescue-disks-string-list.txt", Disk.to_string_list)
      assert_equal IO.read("test/data/rescue-disks-string-list.txt"), Disk.to_string_list
    end
  end


  def test_hpe_disks
    hpe_disks do
     # IO.write("test/data/hpe-disks-string-list.txt", Disk.to_string_list)
      assert_equal IO.read("test/data/hpe-disks-string-list.txt"), Disk.to_string_list
    end
  end


  def test_usb_disks
    usb_disks do
     # IO.write("test/data/usb-disks-string-list.txt", Disk.to_string_list)
      assert_equal IO.read("test/data/usb-disks-string-list.txt"), Disk.to_string_list
    end
  end




end
