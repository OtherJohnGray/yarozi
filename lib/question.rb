class Question

  attr_accessor :list
  attr_reader :task, :subquestions

  def initialize(task=nil) 
    @task = task
    reset
  end

  def reset 
    @subquestions = QuestionList.new(self)
  end

  def ask
    #noop
  end

  def respond
    #noop
  end

  def quit
    exit 1
  end

  def wizard
    @wizard ||= new_wizard
  end

  def new_wizard
    new_dialog.tap do |d|
      d.extra_button = true
      d.extra_label = "next"
      d.ok_label = "back"
      d.default_button = "extra"
      d.notags = true
    end
  end

  def dialog
    @dialog ||= new_dialog
  end

  def new_dialog
    Dialog.new.tap do |d|
      d.logger = log
      d.clear = true
      d.dialog_options = "--no-collapse"
      d.backtitle = "YAROZI - Yet Another Root On ZFS installer"
    end
  end

  def clicked
    case dialog.selected_button
    when "ok"
      "back"
    when "cancel"
      "cancel"
    else
      "next"
    end
  end

end