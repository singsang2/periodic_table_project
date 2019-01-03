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
# require_relative "concerns/findable.rb" I didn't know how to get this work
