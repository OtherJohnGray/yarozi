class Question

  attr_accessor :list
  attr_reader :task, :subquestions

  def initialize(task=nil) 
    @task = task
    @subquestions = QuestionList.new(self)
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
    @wizard ||= configure_wizard
  end

  def configure_wizard
    dialog.tap do |d|
      d.extra_button = true
      d.extra_label = "previous"
      d.ok_label = "next"
      d.yes_label = "next"
      d.no_label = "cancel"
      # d.default_button = "next"
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
    log.info "dialog.selected_button is [#{dialog.selected_button}]"    
    dialog.selected_button
  end

end