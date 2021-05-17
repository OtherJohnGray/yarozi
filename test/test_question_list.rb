require 'test'

class TestQuestionList < Test

  def test_override
    l = QuestionList.new
    l.append "a"
    l << "b"
    l.push "c"
  end

end