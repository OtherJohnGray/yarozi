class Question

  class Dialog < MRDialog

    VPAD = 5
    HPAD = 10

    def msgbox(text="Text Goes Here", height=0, width=0, vpad=VPAD, hpad=HPAD)
      super(text, drows( height, vpad ), dcols( width, hpad ))
    end

    def self.rows
      @rows ||= `tput lines`.to_i
    end

    def self.cols
      @cols ||= `tput cols`.to_i
    end

    def drows(height, vpad)
      log.debug "calling drows with height #{height} and vpad #{vpad} and Question::Dialog.rows of #{Question::Dialog.rows}"
      height > 0 && height < Question::Dialog.rows - vpad ? height : Question::Dialog.rows - vpad
    end

    def dcols(width, hpad)
      log.debug "calling dcols with width #{width} and hpad #{hpad} and Question::Dialog.cols of #{Question::Dialog.cols}"
      width  > 0 && width  < Question::Dialog.cols - hpad ? width  : Question::Dialog.cols - hpad
    end

  end



  def initialize(task) 
    @task = task
  end

  def pretasks
    @task.pretasks
  end

  def posttasks
    @task.posttasks
  end

  def ask
    raise "subclasses of Question must implement the ask() method"
  end

  # allows test stubbing
  def quit(code)
    exit code
  end

  # allows test stubbing
  def dialog
    @dialog ||= (
      dlg = Dialog.new
      dlg.logger = log
      dlg.clear = true
      dlg.dialog_options = "--no-collapse"
      dlg
    )
  end

end