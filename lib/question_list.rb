# Owns responsability for back/next/exit logic
class QuestionList
  extend Forwardable

  attr_reader :questions
  def_delegators :@questions, :length, :each, :[]

  def initialize(superquestion=nil)
    @superquestion = superquestion
    @questions = []
  end

  def append(question)
    question.list = self
    @questions << question
  end

  # ask each question in turn, while responding to back, next, and exit requests.
  # return true if user selects "next" from last question, or false if user selects
  # "back" from first question. Assume question dialog is of type that has ok and
  # cancel buttons rather than yes/no
  def ask
    i = 0
    while i < @questions.length do
      @questions[i].reset
      @questions[i].ask
      case @questions[i].clicked
      when "back"
        if i > 0
          i -= 1
        else
          return false
        end
      when "next"
        @questions[i].respond
        i += 1 if @questions[i].subquestions.ask
      when "cancel"
        quit 1 if Question.new.dialog.yesno("Exit installer without making any changes?",8,76)
      else
        # some other kind of dialog, ignore it and move on to the next question.
        i += 1
      end      
    end
    true
  end

  def quit(code)
    log.debug "quiting with code #{code}"
    exit code
  end

end
