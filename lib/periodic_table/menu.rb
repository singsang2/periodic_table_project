class PeriodicTable::Menu
  attr_accessor :key, :command, :function, :output
  @@all = []

  def initialize(hash)
    hash.each do |key, value|
      self.send("#{key}=", value)
    end
    save
  end

  def self.search(input)
    input.numeric? ? self.search_by_key(input) : self.search_by_command(input)
  end

  def self.search_by_key(key)
    @@all.detect{|x| x.key == key}
  end

  def self.search_by_command(command)
    @@all.detect{|x| x.command == command}
  end

  def save
    @@all << self
  end

  def self.all
    @@all
  end
end
