class ZPool < Array

  def valid?
    errors.empty?
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