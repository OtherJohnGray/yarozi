class Question

  class Dialog < MRDialog

    VPAD = 5
    HPAD = 10

    def msgbox(text="Text Goes Here", height=0, width=0, vpad=VPAD, hpad=HPAD)
      log.debug "Question::Dialog.msgbox: calling msgbox with height of #{height}, width of #{width}, vpad of #{vpad}, hpad of #{hpad}, and text of #{text}"
      super(text, drows( height, vpad ), dcols( width, hpad ))
    end

    def yesno(text="Text Goes Here", height=0, width=0, vpad=VPAD, hpad=HPAD)
      log.debug "Question::Dialog.yesno: calling yesno with height of #{height}, width of #{width}, vpad of #{vpad}, hpad of #{hpad}, and text of #{text}"
      super(text, drows( height, vpad ), dcols( width, hpad ))
    end

    def menu(text="Text Goes Here", items=[], height=0, width=0, menu_height=0, vpad=VPAD, hpad=HPAD)
      log.debug "Question::Dialog.menu: calling yesno with height of #{height}, width of #{width}, menu_height of #{menu_height}, vpad of #{vpad}, hpad of #{hpad}, and text of #{text}"
      super(text, items, drows( height, vpad ), dcols( width, hpad ), menu_height)
    end

    
    def self.rows
      @rows ||= `tput lines`.to_i
    end

    def self.cols
      @cols ||= `tput cols`.to_i
    end

    def drows(height, vpad)
      result = height > 0 && height < Question::Dialog.rows - vpad ? height : Question::Dialog.rows - vpad
      log.debug "Question::Dialog.drows: calling drows with height #{height} and vpad #{vpad} and Question::Dialog.rows of #{Question::Dialog.rows} returned #{result}"
      result
    end

    def dcols(width, hpad)
      result = width  > 0 && width  < Question::Dialog.cols - hpad ? width  : Question::Dialog.cols - hpad
      log.debug "Question::Dialog.dcolsq: calling dcols with width #{width} and hpad #{hpad} and Question::Dialog.cols of #{Question::Dialog.cols} returned #{result}"
      result
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

end