class Task

  def questions 
    @questions ||= QuestionList.new
  end

  def pretasks
    @pretasks  ||= []
  end

  def posttasks
    @posttasks ||= []
  end

  def start
    questions.each {|q|  q.resolve }
    pretasks.each  {|pt| pt.start  }
    perform
    posttasks.each {|pt| pt.start  }
  end

  def perform
    raise "subclasses of Task must implement a perform method"
  end

  def set(name, value)
    self.define_singleton_method name, ->{ value }
  end


end