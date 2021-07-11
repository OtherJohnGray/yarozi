class Dialog < MRDialog

  attr_accessor :default_button, :default_item
  attr_reader :selected_button

  VPAD = 5
  HPAD = 10

  def alert(text="Text Goes Here", height=0, width=0, vpad=VPAD, hpad=HPAD)
    log.debug "Dialog.alert: calling msgbox with height of #{height}, width of #{width}, vpad of #{vpad}, hpad of #{hpad}, and text of #{text}"
    msgbox(text, drows( height, vpad ), dcols( width, hpad ))
  end

  def advise(text="Text Goes Here", height=0, width=0, vpad=VPAD, hpad=HPAD)
    log.debug "Dialog.advise: calling yesno with height of #{height}, width of #{width}, vpad of #{vpad}, hpad of #{hpad}, and text of #{text}"
    yesno(text, drows( height, vpad ), dcols( width, hpad ))
  end

  def ask(text="Text Goes Here", items=[], height=0, width=0, menu_height=0, vpad=VPAD, hpad=HPAD)
    log.debug "Dialog.ask: calling menu with height of #{height}, width of #{width}, menu_height of #{menu_height}, vpad of #{vpad}, hpad of #{hpad}, and text of #{text}"
    menu(text, items, drows( height, vpad ), dcols( width, hpad ), menu_height)
  end

  def input(text="Text Goes Here", items=[], height=0, width=0, formheight=0, vpad=VPAD, hpad=HPAD)
    log.debug "Dialog.input: calling form with height of #{height}, width of #{width}, formheight of #{formheight}, vpad of #{vpad}, hpad of #{hpad}, and text of #{text}"
    form(text, items, drows( height, vpad ), dcols( width, hpad ), formheight)
  end

  def list(text="Text Goes Here", items=[], height=0, width=0, listheight=0, vpad=VPAD, hpad=HPAD)
    log.debug "Dialog.input: calling list with height of #{height}, width of #{width}, listheight of #{listheight}, vpad of #{vpad}, hpad of #{hpad}, and text of #{text}"
    checklist(text, items, drows( height, vpad ), dcols( width, hpad ), listheight)
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
      @selected_button = ( @exit_code == 0 ? "next" : "previous" ) 
      selected_string = tmp.readline
      selected_string
    else
      @selected_button = "cancel"
      false
    end
  ensure
    tmp.close!
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
      @selected_button = ( @exit_code == 0 ? "next" : "previous" ) 
      true
    else
      @selected_button = "cancel"
      false
    end
  end

  def form(text, items, height=0, width=0, formheight=0)
    res_hash = {}
    tmp = Tempfile.new('dialog') 
    itemlist = ''
    mixed_form = false
    item_size = items[0].size
    log_debug "Item size:#{item_size}"
    # if there are 9 elements, it's a mixedform
    if item_size == 9
        mixed_form = true
    end
    items.each do |item|
      itemlist << '"'
      itemlist << item[0].to_s
      itemlist << '"'
      itemlist << " "
      itemlist << item[1].to_s
      itemlist << " "
      itemlist << item[2].to_s
      itemlist << " "
      itemlist << '"'
      itemlist << item[3].to_s
      itemlist << '"'
      itemlist << " "
      itemlist << item[4].to_s
      itemlist << " "
      itemlist << item[5].to_s
      itemlist << " "
      itemlist << item[6].to_s
      itemlist << " "
      itemlist << item[7].to_s
      itemlist << " "
      if mixed_form
          itemlist << item[8].to_s
          itemlist << " "
      end
    end
    itemlist << " "
    itemlist << "2>"
    itemlist << tmp.path

    cmd = ""
    cmd << option_string()
    cmd << " "
    if mixed_form
      cmd << "--mixedform"
    else
      if @password_form
        cmd << "--passwordform"
      else
        cmd << "--form"
      end
    end
    cmd << " "
    cmd << '"'
    cmd << text
    cmd << '"'
    cmd << " "
    cmd << height.to_s
    cmd << " "
    cmd << width.to_s
    cmd << " "
    cmd << formheight.to_s
    cmd << " "
    cmd << itemlist

    log_debug("Number of items: #{items.size}")
    log_debug("Command:\n#{cmd}")
    system(cmd)
    @exit_code = $?.exitstatus
    log_debug "Exit code: #{exit_code}"

    if @exit_code != 1
      @selected_button = ( @exit_code == 0 ? "next" : "previous" ) 
      lines = tmp.readlines
      lines.each_with_index do |val, idx|
          key = items[idx][0]
          res_hash[key] = val.chomp
      end
      res_hash
    else
      @selected_button = "cancel"
      false
    end
  ensure
    tmp.close!
  end


  def checklist(text, items, height=0, width=0, listheight=0)
    
    tmp = Tempfile.new('tmp')

    itemlist = String.new

    for item in items
      if item[2]
        item[2] = "on"
      else
        item[2] = "off"
      end
      itemlist += "\"" + item[0].to_s + "\" \"" + item[1].to_s + 
      "\" " + item[2] + " "

      if @itemhelp
        itemlist += "\"" + item[3].to_s + "\" "
      end
    end

    command = option_string() + "--checklist \"" + text.to_s +
                        "\" " + height.to_i.to_s + " " + width.to_i.to_s +
      " " + listheight.to_i.to_s + " " + itemlist + "2> " +
      tmp.path 
      log_debug "Command:\n#{command}"
    success = system(command)
    @exit_code = $?.exitstatus
    selected_array = []

    if @exit_code != 1
      @selected_button = ( @exit_code == 0 ? "next" : "previous" ) 
      if tmp.size > 0
        selected_string = tmp.readline
        a = selected_string.split(" ")
        a.each do |item|
          log_debug ">> #{item}"
          selected_array << item if item && item.to_s.length > 0
        end
      end
      selected_array
    else
      @selected_button = "cancel"
      false
    end
  ensure
    tmp.close!
  end
end
