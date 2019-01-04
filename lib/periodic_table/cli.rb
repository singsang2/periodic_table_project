class PeriodicTable::CLI
  #saves last searched elements
  @@history = []

  def start
    @location = "start" #stores current method location
    @menu = PeriodicTable::Menu
    @header = PeriodicTable::Header

    greeting  #displays greeting messages
    scrape_elements #scrapes elements from website
    menu  #displays menu
  end

  def greeting
    clear
    puts "Welcome to CLI Periodic Table Project"
  end

  def scrape_elements
    start = Time.now
    puts "Scraping elements from wikipedia..."
    PeriodicTable::Scraper.element_scraper
    finish = Time.now

    puts "Done! Scraping time: #{finish - start} seconds.\n\n"
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
    input = gets.strip.downcase

    #send the input the #option
    option(input)
  end

  def search_menu
    print "Write "
  end

  def header(location)
    header = @header.search_by_key(location)
    puts "="*20+ header.title + "="*20
    puts header.description
    @location = location
  end

  #directs the program where to head
  def option(input)
    find = @menu.search(input)

    if input == "clear"
      clear
      menu
    elsif find != nil
      self.send("#{find.output}")
    else
      puts "ME NO UNDERSTAND YOU! \\_(-___-)_/ Please try again."
      menu  #repeat the menu if user input is not valid
    end
  end

  def list
    save(PeriodicTable::Elements.all)

    #prevents repeatedly showing where the user is
    header("list") unless @location == "list"

    display_table(@@history) #default argument: all elements
    menu
  end

  def search
    #prevents repeatedly showing where the user is
    header("search") unless @location == "search"

    print "Write symbol/name/atomic number of an element to search:"
    input = gets.strip.downcase
    search_by_input(input)
    choose_element_properties
  end

  def search_by_input(input)
    start = Time.now
    #to prevent calling #search_by_name_or_symbol multiple times
    find = search_by_name_or_symbol(input)
    header = @header.search_by_key(@location)

    #can deal with three possible user inputs: atomic #, symbol, and name
    if input == "menu"
      menu
    elsif input == "clear"
      clear
      self.send("#{@location}")
    elsif input == "exit"
      puts "Goodbye!"
      exit
    elsif valid_numeric?(input, header)
      find = self.send("search_by_#{header.search_type}_number",input)
      display_table(find) #only displays searched element(s)
      finish = Time.now
      puts "Search time: #{finish - start} seconds.\n\n"
    elsif find != nil
      binding.pry
      find = self.send("search_by_#{header.search_type}_number", find.send("#{@location}")) if @location != "search"
      display_table(find) #only displays searched element(s)
      finish = Time.now
      puts "Search time: #{finish - start} seconds.\n\n"
    else
      puts "Could not find #{input} from the list!"
      puts "Please write a number between 1-#{header.length} or a valid element name/symbol!"
      puts "Press any key go back to the previous search..."
      gets.strip
      self.send("#{@location}") #loops until a valid option is made
    end
  end

  def valid_numeric?(input, header)
    input.numeric? && input.to_i.between?(1,header.length)
  end

  #allows user to search elements by their group number or an element symbol/name
  def group
    #prevent repeatedly printing out where the user is
    header("group") unless @location == "group"

    print "Write group number(1-18) or symbol/name of an element: "
    input = gets.strip.downcase

    search_by_input(input)
    # start = Time.now
    #
    # #in case user has written name or symbol
    # element_by_name = search_by_name_or_symbol(input)
    #

    # if input == "menu"
    #   menu
    # elsif input == "clear"
    #   clear
    #   group
    # elsif input == "exit"
    #   puts "Goodbye!"
    #   exit
    # elsif input.numeric? && input.to_i.between?(1,18)
    #   find = search_by_group_number(input)
    #   display_table(find)
    #   finish = Time.now
    #   puts "Search time: #{finish - start} seconds.\n\n"
    #   menu
    # elsif element_by_name != nil
    #   save([element_by_name]) #saves searched group of elements into @@history
    #   find = search_by_group_number(element_by_name.group)
    #   display_table(find)
    #   finish = Time.now
    #   puts "Search time: #{finish - start} seconds.\n\n"
    #   menu
    # else
    #   puts "Please write a number between 1-18 or a valid element name/symbol!"
    #   group #loops
    # end
  end

  # def group_header
  #   puts "="*12+" SEARCH BY GROUP " + "="*12
  #   puts "You can search elements with same group using group number or writing symbol/name of an element!"
  # end


  def period
    header("period") unless @location == "period"

    print "Write period number(1-7) or symbol/name of an element: "
    input = gets.strip.downcase

    start = Time.now
    element_by_name = search_by_name_or_symbol(input)

    if input == "menu"
      menu
    elsif input == "clear"
      clear
      period
    elsif input == "exit"
      puts "Goodbye!"
      exit
    elsif input.numeric? && input.to_i.between?(1,7)
      find = search_by_period_number(input)
      display_table(find)
      finish = Time.now
      puts "Search time: #{finish - start} seconds.\n\n"
      menu
    elsif element_by_name != nil
      save([element_by_name]) #saves the searched elements into @@history
      find = search_by_period_number(element_by_name.group)
      display_table(find)
      finish = Time.now
      puts "Search time: #{finish - start} seconds.\n\n"
      menu
    else
      puts "Please write a number between 1-7 or a valid element name/symbol!"
      period
    end
  end

  def properties
    #binding.pry
    len = @@history.length
    if len == 1
      scrape_properties(@@history[0])
    else
      choose_element_properties
    end
  end

  def choose_element_properties
    puts "* Write 'menu' to go back to the main menu"
    print "Write either (1)atomic number, (2) symbol, or (3) name of the element you would like to see more about: "
    input = gets.strip.downcase

    if input == "menu"
      menu
    elsif input == "clear"
      clear
      period
    elsif input == "exit"
      puts "Goodbye!"
      exit
    elsif input.numeric? && @@history.map{|element| element.Z}.include?(input)
      scrape_properties(@@history.detect {|element| element.Z == input})
    elsif search_by_name_or_symbol(input, @@history) != nil
      scrape_properties(search_by_name_or_symbol(input, @@history))
    else
      clear
      puts "Invalid choice! Please choose one of the elements provided in the list below!\n\n"
      display_table(@@history)
      choose_element_properties

    end
  end

  def scrape_properties(find)
    start = Time.now
    if find.properties == nil
      puts "Scraping proprtiess from wikipedia..."
      PeriodicTable::Scraper.property_scraper(find)
    else
      puts "loading from file..."
    end

    display_properties(find.properties)
    finish = Time.now
    puts "Done! Loading time: #{finish - start} seconds.\n\n"

    puts "Please click anything to go back to the menu..."
    gets.strip #pauses for the user to click anything
    clear
    display_table(@@history)
    menu
  end

  def clear
    system "clear" #clears terminal
  end

  # displays sorted elements - default value is all elements
  def display_table(elements = PeriodicTable::Elements.all)
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
    find
  end

  def search_by_atomic_number(number)
    find = PeriodicTable::Elements.all.map {|element| element if element.Z == number}.compact
    find
  end

  def search_by_group_number(number)
    find = PeriodicTable::Elements.all.map {|element| element if element.group == number}.compact
    save(find)
    find
  end

  def search_by_period_number(number)
    find = PeriodicTable::Elements.all.map {|element| element if element.period == number}.compact
    save(find)
    find
  end
  ##########################################################################
  ##########################################################################


  def save(elements)
    #saves the elements as an array if it's one element
    elements.class == Array ? @@history = elements : @@history = [elements]
  end

end

#Used to check whether a string is numeric or not
class String
  def numeric?
    true if Float(self) rescue false
  end
end
