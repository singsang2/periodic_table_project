class PeriodicTable::Scraper
  def self.element_scraper(path="https://en.wikipedia.org/wiki/List_of_chemical_elements")
    elements = Nokogiri::HTML(open(path))
    #binding.pry
    self.get_table(elements).each do |element|
      #construct hash that contains element data (symbol, name, atomic number, atomic mass)
      #binding.pry
      hash = {
        name: element.css("td")[2].text,
        symbol: element.css("td")[1].text,
        Z: element.css("td")[0].text, #atomic number
        atomic_weight: element.css("td")[6].children[0].text,
        group:element.css("td")[4].text,
        period:element.css("td")[5].text,
        name_origin: element.css("td")[3].text,
        url: "https://en.wikipedia.org" + element.css("td")[2].children.attribute("href").value
      }
      PeriodicTable::Elements.new(hash)
    end
  end

  def self.get_table(elements)
    #first two rows and the last row are not part of the data
    elements.elements.css("table.wikitable tbody tr")[3..-2]
  end

  def self.property_scraper(element)
    properties = Nokogiri::HTML(open(element.url))
    keys = ['appearance', 'block', "phase", "melting", "boiling", "density", "oxidation"]
    hash = {}

    properties.css("table.infobox tr").each do |node|
      header = node.css("th").text.downcase

      if header.include?(Nokogiri::HTML("&nbsp;").text)
        key = header.partition(Nokogiri::HTML("&nbsp;").text).first
      elsif header.include?(" ")
        key = header.partition(" ").first
      else
        key = header
      end
      hash[key.to_sym] = node.css("td").text.strip if keys.include?(key)
    end

    #just get first 600 words from the paragraph.
    hash[:summary] = Nokogiri::HTML(properties.css("div.mw-content-ltr p").text).text[0,600] + "..."
    element.properties = PeriodicTable::Properties.new(hash)
  end
end
