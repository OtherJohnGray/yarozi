require 'forwardable'

# Owns responsability for back/next/exit logic
class QuestionList
  extend Forwardable

  attr_reader :questions
  def_delegators :@questions, :length, :first, :last, :each, :[]

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
      log.info "resetting question #{i}"
      @questions[i].reset
      log.info "asking question #{i}"
      @questions[i].ask
      case @questions[i].clicked
      when "back"
        if i > 0
          log.info "going back..."
          i -= 1
        else
          log.info "returning false from question list"
          return false
        end
      when "next"
        log.info "calling respond on question #{i}"
        @questions[i].respond
        log.info "starting questions #{i}'s subquestions..."
        i += 1 if @questions[i].subquestions.ask
      when "cancel"
        log.info "cancelling from question #{i}"
        quit 1 if Dialog.new.yesno("Exit installer without making any changes?",5,46)
      else
        log.info "got unknown response from question #{i}, advancing to next question"
        # some other kind of dialog, ignore it and move on to the next question.
        i += 1
      end      
    end
    log.info "finished question list, returning true..."
    true
  end

  def quit(code)
    log.debug "quiting with code #{code}"
    exit code
  end

end
