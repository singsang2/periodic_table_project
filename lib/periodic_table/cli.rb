class PeriodicTable::CLI
  #saves pervious search history
  @@history = []

  MENU = [{key: "1", command: "list", function:"lists all elements"},
        {key: "2", command: "search", function:"search for an element"},
        {key: "3", command: "group", function:"lists elements by groups"},
        {key: "4", command: "period", function:"lists elements by periods"},
        {key: "5", command: "exit", function:"Exit from the program"}]

  def start
    @location = "start"
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
    @location = "menu"
    #displays the menu
    puts "="*16+" M E N U " + "="*16
    tp MENU
    puts "-"*41

    #asks for user input from the menu
    print "Please write key number or command: "
    input = gets.strip.downcase

    if valid?(input)
      case input
      when MENU[0].values[0], MENU[0].values[1]
        list
      when MENU[1].values[0], MENU[1].values[1]
        search
      when MENU[2].values[0], MENU[2].values[1]
        group
      when MENU[3].values[0], MENU[3].values[1]
        period
      when MENU[4].values[0], MENU[4].values[1]
        exit
      when "clear"
        clear
      end
    else
      menu  #repeat the menu if user input is not valid
    end
  end

  #checks whether user input is valid option or not
  def valid?(input)
    if input.numeric?
      input.to_i.between?(1,MENU.length) ? true : false
    else
      #checks whether input is one of the commands or not
      MENU.map{|option| option[:command]}.include?(input) ? true : false
    end
  end

  def list
    display_table
    menu
  end

  def search
    puts "="*16+" SEARCH " + "="*16 unless @location == "search"
    @location = "search"
    print "Write symbol/name/atomic number of element you would like to search: "
    input = gets.strip.downcase

    start = Time.now
    find = search_by_name_or_symbol(input)

    if input.numeric? && input.to_i.between?(1,118)
      find = search_by_atomic_number(input)
      save([find])
      display_table(find)
      finish = Time.now
      puts "Search time: #{finish - start} seconds.\n\n"
      options
    elsif find != nil
      save([find])
      display_table(find)
      finish = Time.now
      puts "Search time: #{finish - start} seconds.\n\n"
      options
    else
      puts "Please write a number between 1-118 or a valid element name/symbol!"
      search
    end

  end

  def group
    puts "="*12+" SEARCH BY GROUP " + "="*12 unless @location == "group"
    @location = "group"
    print "Which group of elements would you like to see (1-18): "
    input = gets.strip.downcase

    start = Time.now
    element_by_name = search_by_name_or_symbol(input)
    save([element_by_name])

    if input.numeric? && input.to_i.between?(1,18)
      find = search_by_group_number(input)
      display_table(find)
      finish = Time.now
      puts "Search time: #{finish - start} seconds.\n\n"
      options
    elsif element_by_name != nil
      find = search_by_group_number(element_by_name.group)
      display_table(find)
      finish = Time.now
      puts "Search time: #{finish - start} seconds.\n\n"
      options
    else
      puts "Please write a number between 1-18 or a valid element name/symbol!"
      group
    end
  end


  def period
    puts "="*12+" SEARCH BY PERIOD " + "="*12 unless @location == "period"
    @location = "period"
    print "Which group of elements would you like to see (1-7): "
    input = gets.strip.downcase

    start = Time.now
    element_by_name = search_by_name_or_symbol(input)
    save([element_by_name])

    if input == "menu"
      menu
    elsif input == "clear"
      clear
      period
    elsif input == "exit"
      puts "Good bye!"
      exit
    elsif input.numeric? && input.to_i.between?(1,7)
      find = search_by_period_number(input)
      display_table(find)
      finish = Time.now
      puts "Search time: #{finish - start} seconds.\n\n"
      options
    elsif element_by_name != nil
      find = search_by_period_number(element_by_name.group)
      display_table(find)
      finish = Time.now
      puts "Search time: #{finish - start} seconds.\n\n"
      options
    else
      puts "Please write a number between 1-7 or a valid element name/symbol!"
      group
    end
  end

  def options
    menu_detail = [{key: "1", command: "search", function: "search#{@location == "search" ? "" : " by " + @location} options"},
          {key: "2", command: "detail", function:"display details"},
          {key: "3", command: "menu", function:"goes back to main menu"},
          {key: "4", command: "exit", function:"Exit from the program"}]
    puts "="*16+"OPTIONS" + "="*15
    tp menu_detail
    puts "-"*38

    print "What would you like to do: "
    input = gets.strip.downcase

    case input
    when "1", "search"
      self.send("#{@location}")
    when "2", "detail"
      properties
    when "3", "menu"
      clear
      menu
    when "clear"
      clear
      self.send("#{@location}")
    when "4", "exit"
      puts "Good Bye!"
      exit
    else
      puts "Input not recognized!"
      options
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
    print "Write either (1)atomic number, (2) symbol, or (3) name of the element you would like to see more about: "
    input = gets.strip.downcase
    if input.numeric? && @@history.map{|element| element.Z}.include?(input)
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
    puts "Scraping proprtiess from wikipedia..."
    #binding.pry
    PeriodicTable::Scraper.property_scraper(find) if find.properties == nil

    display_properties(find.properties)
    finish = Time.now
    puts "Done! Scraping time: #{finish - start} seconds.\n\n"

    puts "Please click anything to go back to the menu..."
    gets.strip #pauses for the user to click anything
    clear
    display_table(@@history)
    options
  end

  def clear
    system "clear" #clears terminal
  end

  # displays sorted elements - default value is all elements
  def display_table(elements = PeriodicTable::Elements.all)
    tp elements, :Z, :symbol, :name, :group, :period, :atomic_weight
  end

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
    puts "-"*(57+name.length)
    puts "-"*20 + "#{name} DETAILED SUMMARY" +"-"*20
    puts "-"*(57+name.length)
    puts "\n\n"
  end

  # Search options
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

  def save(elements)
    @@history = elements
  end

end

#Used to check whether a string is numeric or not
class String
  def numeric?
    true if Float(self) rescue false
  end
end
