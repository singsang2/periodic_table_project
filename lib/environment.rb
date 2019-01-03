require 'nokogiri'
require 'pry'
require 'open-uri'
require 'table_print'
module PeriodicTable
  class Error < StandardError; end
  # Your code goes here...
end


require_relative "periodic_table/version.rb"
require_relative "periodic_table/cli.rb"
require_relative "periodic_table/elements.rb"
require_relative "periodic_table/properties.rb"
require_relative "periodic_table/scraper.rb"
require_relative "periodic_table/menu.rb"
require_relative "periodic_table/header.rb"
# require_relative "concerns/findable.rb" I didn't know how to get this work

HEADER = [{key: "list", title: "LIST OF ALL ELEMENTS", description: "Lists all the element."},
          {key: "search", title: "SEARCH AN ELEMENT", description: "You can search for an element by writing atomic number, name, or symbol of an element.", length: 118, search_type: "atomic"},
          {key:"group", title: "SEARCH BY GROUP", description: "You can search for elements with same group by group number(1-18), name, or symbol of an element in the group.", length: 18, search_type: "group"},
          {key:"period", title: "SEARCH BY PERIOD", description: "You can search for elements with same period by period number(1-7), name, or symbol of an element in the period.", length: 7, search_type: "period"}]

#main menu
MENU = [{key: "1", command: "list", function:"lists all elements", output: "list"},
      {key: "2", command: "search", function:"search an element", output: "search_an_element"},
      {key: "3", command: "group", function:"lists elements by groups", output: "group"},
      {key: "4", command: "period", function:"lists elements by periods", output: "period"},
      {key: "5", command: "detail", function:"displays detailed information", output: "choose_element_properties"},
      {key: "6", command: "exit", function:"Exit from the program", output: "exit"}]
MENU.each {|menu|PeriodicTable::Menu.new(menu)}
HEADER.each {|header|PeriodicTable::Header.new(header)}
