class QuestionList

  def append(question)
    question.list = self
    (@questions ||= []) << question
  end

  def initialize(superquestion=nil)
    @superquestion = superquestion
  end

end