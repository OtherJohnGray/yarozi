class Task

  attr_accessor :questions, :pretasks, :posttasks

  def initialize
    @questions = QuestionList.new
    @pretasks  = []
    @posttasks = []
  end
  

  def start
    @questions.ask
    @pretasks.each  {|t| t.start  }
    perform
    @posttasks.each {|t| t.start  }
  end

  def perform
    raise "subclasses of Task must implement a perform method"
  end

  def set(name, value)
    self.define_singleton_method name, ->{ value }
  end


end