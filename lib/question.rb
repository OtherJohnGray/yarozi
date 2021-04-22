class Question

  def initialize(task) 
    @task = task
  end

  def pretasks
    @task.pretasks
  end

  def posttasks
    @task.posttasks
  end

  def ask
    raise "subclasses of Question must implement the ask() method"
  end

  # allows test stubbing
  def quit(code)
    exit code
  end

  # allows test stubbing
  def dialog
    @dialog ||= (
      dlg = MRDialog.new
      dlg.logger = log
      dlg.clear = true
      dlg
    )
  end

  def cols
    `tput cols`.to_i
  end

  def rows
    `tput lines`.to_i
  end

  def dcols
    cols - 10
  end

  def drows
    rows - 5
  end

end