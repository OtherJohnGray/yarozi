# Helper class used by YVN class.
# Holds a list of VDEV definitions that result from parsing a YVN string.
#
# If you are looking for the class that actually holds the ZPool and VDEV
# information that will be used to build the system, look at layout.rb.
# Layout is used from within root_installer/questions/partitions.rb to 
# store generated VDEV and Pool specifications, and provides validation
# of the layout of VDEVs across the various disks of the system.
class ZPool < Array

  def valid?
    errors.empty?
  end

  def invalid?
    !valid?
  end

  def errors
    [].tap do |err|
      each_with_index do |vdev, i|
        vdev.errors.each do |v_error|
          err << "#{i+1} #{v_error}"
        end
      end
    end
  end
end