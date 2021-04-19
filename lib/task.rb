class Task

  def questions 
    @questions ||= []
  end

  def pretasks
    @pretasks  ||= []
  end

  def posttasks
    @posttasks ||= []
  end

  def start
    questions.each {|q|  q.ask    }
    pretasks.each  {|pt| pt.start }
    perform
    posttasks.each {|pt| pt.start }
  end

  def perform
    raise "subclasses of Task must implement a perform method"
  end


end