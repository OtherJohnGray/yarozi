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
    dialog ||= MRDialog.new
    dialog.logger = Logger.new("./log/mrdialog.log")
    dialog.clear = true
    dialog
  end

end