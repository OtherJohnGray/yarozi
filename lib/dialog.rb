class Dialog < MRDialog

  attr_accessor :default_button, :default_item
  attr_reader :selected_button

  VPAD = 5
  HPAD = 10

  def alert(text="Text Goes Here", height=0, width=0, vpad=VPAD, hpad=HPAD)
    log.debug "Dialog.msgbox: calling msgbox with height of #{height}, width of #{width}, vpad of #{vpad}, hpad of #{hpad}, and text of #{text}"
    msgbox(text, drows( height, vpad ), dcols( width, hpad ))
  end

  def advise(text="Text Goes Here", height=0, width=0, vpad=VPAD, hpad=HPAD)
    log.debug "Dialog.yesno: calling yesno with height of #{height}, width of #{width}, vpad of #{vpad}, hpad of #{hpad}, and text of #{text}"
    yesno(text, drows( height, vpad ), dcols( width, hpad ))
  end

  def ask(text="Text Goes Here", items=[], height=0, width=0, menu_height=0, vpad=VPAD, hpad=HPAD)
    log.debug "Dialog.menu: calling yesno with height of #{height}, width of #{width}, menu_height of #{menu_height}, vpad of #{vpad}, hpad of #{hpad}, and text of #{text}"
    menu(text, items, drows( height, vpad ), dcols( width, hpad ), menu_height)
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
  def option_string
    ostring = super
    if @default_button
      ostring += "--default-button #{@default_button} "
    end
    if @default_item
      ostring += "--default-item #{@default_item} "
    end
    ostring
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
    @success = system(command)
    @exit_code = $?.exitstatus

    if @exit_code != 1
      @selected_button = ( @exit_code == 0 ? "back" : "next" ) 
      selected_string = tmp.readline
      tmp.close!
      return selected_string
    else
      @selected_button = "cancel"
      tmp.close!
      return false
    end
    
  end

  def yesno(text="Please enter some text", height=0, width=0)
    #    command = option_string() + "--inputbox \"" + text.to_s +
    #                "\" " + height.to_i.to_s + " " + width.to_i.to_s
    
    command = ""
    command << option_string();
    command << " "
    command << '"'
    command << "--yesno"
    command << '"'
    command << " "
    command << '"'
    command << text
    command << '"'
    command << " "
    command << height.to_s
    command << " "
    command << width.to_s


    log_debug("Command:\n#{command}")
    @success = system(command)
    @exit_code = $?.exitstatus
    if @exit_code != 1
      @selected_button = ( @exit_code == 0 ? "back" : "next" ) 
      true
    else
      @selected_button = "cancel"
      false
    end
  end

end
