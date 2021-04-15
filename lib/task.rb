class Task

  attr_reader :questions, :subtasks

  def initialize
    decisions = []
    subtasks = []
  end

  def complete
    questions.each do |q|
      q.ask
    end
    subtasks.each do |st|
      st.perform
    end
  end

  def perform
    raise "subclasses of Task must implement a perform method"
  end


end