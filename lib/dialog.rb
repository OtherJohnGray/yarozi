class Dialog < MRDialog

  attr_accessor :default_button
  attr_reader :selected_button

  VPAD = 5
  HPAD = 10

  def msgbox(text="Text Goes Here", height=0, width=0, vpad=VPAD, hpad=HPAD)
    log.debug "Dialog.msgbox: calling msgbox with height of #{height}, width of #{width}, vpad of #{vpad}, hpad of #{hpad}, and text of #{text}"
    super(text, drows( height, vpad ), dcols( width, hpad ))
  end

  def yesno(text="Text Goes Here", height=0, width=0, vpad=VPAD, hpad=HPAD)
    log.debug "Dialog.yesno: calling yesno with height of #{height}, width of #{width}, vpad of #{vpad}, hpad of #{hpad}, and text of #{text}"
    super(text, drows( height, vpad ), dcols( width, hpad ))
  end

  def menu(text="Text Goes Here", items=[], height=0, width=0, menu_height=0, vpad=VPAD, hpad=HPAD)
    log.debug "Dialog.menu: calling yesno with height of #{height}, width of #{width}, menu_height of #{menu_height}, vpad of #{vpad}, hpad of #{hpad}, and text of #{text}"
    super(text, items, drows( height, vpad ), dcols( width, hpad ), menu_height)
  end

  
  def self.rows
    @rows ||= `tput lines`.to_i
  end

  def self.cols
    @cols ||= `tput cols`.to_i
  end

  def drows(height, vpad)
    result = height > 0 && height < Dialog.rows - vpad ? height : Dialog.rows - vpad
    log.debug "Dialog.drows: calling drows with height #{height} and vpad #{vpad} and Dialog.rows of #{Dialog.rows} returned #{result}"
    result
  end

  def dcols(width, hpad)
    result = width  > 0 && width  < Dialog.cols - hpad ? width  : Dialog.cols - hpad
    log.debug "Dialog.dcols: calling dcols with width #{width} and hpad #{hpad} and Dialog.cols of #{Dialog.cols} returned #{result}"
    result
  end

  # override MRDialog methods

  if @default_button
    ostring += "--default-button #{@default_button} "
  end


  def menu(text="Text Goes Here", items=nil, height=0, width=0, listheight=0)
    tmp = Tempfile.new('tmp')

    itemlist = String.new

    for item in items
      itemlist += "\"" + item[0].to_s + "\" \"" + item[1].to_s +  "\" "

      if @itemhelp
        itemlist += "\"" + item[2].to_s + "\" "
      end
    end

    command = option_string() + "--menu \"" + text.to_s +
              "\" " + height.to_i.to_s + " " + width.to_i.to_s +
              " " + listheight.to_i.to_s + " " + itemlist + "2> " +
              tmp.path

    log_debug("Command:\n#{command}")
    success = system(command)
    @exit_code = $?.exitstatus

    if @exit_code != 1
      @selected_button = ( @exit_code == 0 ? :ok : :extra ) 
      selected_string = tmp.readline
      tmp.close!
      return selected_string
    else
      @selected_button = :cancel
      tmp.close!
      return false
    end
    
  end

end
