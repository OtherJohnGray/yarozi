class Question

  attr_accessor :list, :subquestions
  attr_reader :task, :dialog

  def initialize(task=nil) 
    @task = task
    @dialog = new_dialog
  end

  def reset 
    @subquestions = QuestionList.new(self)
  end

  def new_dialog
    Dialog.new.tap do |d|
      d.logger = log
      d.clear = true
      d.dialog_options = "--no-collapse"
      d.backtitle = "YAROZI - Yet Another Root On ZFS installer"
      d.extra_button = true
      d.extra_label = "next"
      d.ok_label = "back"
      d.default_button = "extra"
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