class PeriodicTable::CLI
  def start
    @location = "start" #stores current method location
    @menu = PeriodicTable::Menu # all menu + their options
    @header = PeriodicTable::Header # all possible headers
    @history = [] #stores previous search history
    @main = ["menu", "exit", "clear"] #user can use these prompt inner menus
    greeting  #displays greeting messages
    scrape_elements #scrapes elements from website
    menu  #displays menu
  end

  def greeting
    clear
    puts "Welcome to CLI Periodic Table Project"
  end

  def scrape_elements
    @start = Time.now
    puts "Scraping elements from wikipedia..."
    PeriodicTable::Scraper.element_scraper
    @finish = Time.now

    puts "Done! Scraping time: #{@finish - @start} seconds.\n\n"
  end

  def menu
    #displays the menu
    if @location != "menu"
      puts "="*18+" M E N U " + "="*18
      tp @menu.all, :key, :command, :function
      puts "-"*45
    end
    @location = "menu" #current location

    #asks for user input from the menu
    print "Please write key number or command: "
    user_input = gets.strip.downcase

    if valid?(user_input)
      input = @menu.search(user_input)
      self.send(input.command)
    else
      puts "ME NO UNDERSTAND YOU! \\_(-___-)_/ Please try again."
      menu # repeats the menu until valid input
    end
  end

  #checks whether the user input is a valid choice or not
  def valid?(input)
    @menu.search(input) != nil
  end

  # prints out appropriate header for different methods
  def header(location)
    header = @header.search_by_key(location)
    puts "="*20+ header.title + "="*20
    puts header.description
    @location = location
  end

  def list
    header("list")
    display_table(PeriodicTable::Elements.all) #default argument: all elements
    menu
  end

  def search
    #prevents repeatedly showing where the user is
    header("search") unless @location == "search"
    submenu
    # find = search_by_input(input)
  end

  def group
    header("group") unless @location == "group"
    submenu
  end

  def period
    header("period") unless @location == "period"
    submenu
  end

  def submenu
    print @menu.search(@location).ask
    input = gets.strip.downcase
    header = @header.search_by_key(@location)

    if @main.include?(input) #in case the user input is one of 'main', 'exit', 'clear' commands
      self.send(input)
    else
      find = search_by_input(input)

      if valid_find?(find)
        save(find)
        display_table
        element_property
      elsif valid_find?(find) && @history == []
        puts "Element '#{search_by_name_or_symbol(input).name.capitalize} - #{search_by_name_or_symbol(input).symbol.capitalize}' does not have a group number. Remember Lathanides and Actinides do not have group numbers!"
        puts "Press any key go back to the previous search..."
        gets.strip
        submenu
      else
        puts "Could not find '#{input.capitalize}' from the list!"
        puts "Please write a number between 1-#{header.length} or a valid element name/symbol!"
        puts "Press any key go back to the previous search..."
        gets.strip
        submenu
      end
    end
  end

  # checks if the search result is valid (not nil)
  def valid_find?(find)
    find != nil
  end

  def search_by_input(input)
    @start = Time.now
    find = search_by_name_or_symbol(input)
    type = @header.search_by_key(@location).search_type

    #can deal with three possible user inputs: atomic #, symbol, and name
    if valid_numeric?(input)
      #uses appropriate search method
      find = self.send("search_by_#{type}_number",input)
    #  binding.pry
    elsif find != nil
      #uses appropriate search method
      find = self.send("search_by_#{type}_number",find)
    else
      nil
    end
  end

  #checks whether numeric input is between a valid parameter: group (1-18) period(1-7)
  def valid_numeric?(input)
    input.numeric? && input.to_i.between?(1,@header.search_by_key(@location).length)
  end

  def element_property
    puts "* menu - to go back to the main menu."
    puts "* exit - to exit out of the program"
    puts "* r -  to repeat the search#{ " by " + (@location) if @location != "search"}."

    print @header.search_by_key(@location).search_option
    input = gets.strip.downcase
    if @main.include?(input) #in case the user input is one of 'main', 'exit', 'clear' commands
      self.send(input)
    elsif input == "r"
      self.send(@location)
    elsif input == "" && @location == "search"
      scrape_properties(@history[0])
    elsif input.numeric? && @history.map{|element| element.Z}.include?(input)
      scrape_properties(@history.detect {|element| element.Z == input})
    elsif search_by_name_or_symbol(input, @history) != nil
      scrape_properties(search_by_name_or_symbol(input, @history))
    else
      clear
      puts "Invalid choice! Please choose one of the elements provided in the list below!\n\n"
      display_table(@history)
      element_property
    end
  end

  def scrape_properties(find)
    @start = Time.now
    if find.properties == nil
      puts "Scraping proprtiess from wikipedia..."
      PeriodicTable::Scraper.property_scraper(find)
    else
      puts "loading from database..."
    end

    display_properties(find.properties)
    @finish = Time.now
    puts "Done! Loading time: #{@finish - @start} seconds.\n\n"

    puts "Please click anything to go back to the menu..."
    gets.strip #pauses for the user to click anything
    clear
    display_table(@history)
    element_property
  end

  def clear
    system "clear" #clears terminal
  end

  # displays sorted elements - default value is all elements
  def display_table(elements = @history)
    tp elements, :Z, :symbol, :name, :group, :period, :atomic_weight
  end

  #displays detailed information of an element
  def display_properties(properties)
    print_summary_header(properties.element.name)
    display_table(properties.element)
    puts "\n"
    tp properties, :appearance, :block, :oxidation
    puts "\n"
    tp properties, :melting, :boiling
    puts "\n"
    puts "Name Origin:"
    puts "------------"
    puts properties.element.name_origin
    puts "\n"
    puts properties.summary
    puts "\n\n"
  end

  def print_summary_header(name)
    clear
    puts "\n\n"
    puts "-"*(57+name.length) #adjusts depending on length of element name
    puts "-"*20 + "#{name} DETAILED SUMMARY" +"-"*20
    puts "-"*(57+name.length)
    puts "\n\n"
  end

  ##########################################################################
  ############################### Search menu ###########################
  ##########################################################################
  # I wanted to put these in different module, but I kept getting noname error...
  def search_by_name_or_symbol(name, elements = PeriodicTable::Elements.all)
    find = elements.detect {|element| element.name.downcase == name || element.symbol.downcase == name}
    save(find) if @location == "search"
    find
  end

  def search_by_atomic_number(input)
    input.class != PeriodicTable::Elements ? number = input : number = input.Z
    find = PeriodicTable::Elements.all.map {|element| element if element.Z == number}.compact
    save(find) if @location == "search"
    find
  end

  def search_by_group_number(input)
    input.class != PeriodicTable::Elements ? number = input : number = input.group
    find = PeriodicTable::Elements.all.map {|element| element if element.group == number}.compact
    save(find)
    find
  end

  def search_by_period_number(input)
    #binding.pry
    input.class != PeriodicTable::Elements ? number = input : number = input.period
    find = PeriodicTable::Elements.all.map {|element| element if element.period == number}.compact
    save(find)
    find
  end
  ##########################################################################
  ##########################################################################


  def save(elements)
    #saves the elements as an array if it's one element
    elements.class == Array ? @history = elements : @history = [elements]
  end
end

#Used to check whether a string is numeric or not
class String
  def numeric?
    true if Float(self) rescue false
  end
end
