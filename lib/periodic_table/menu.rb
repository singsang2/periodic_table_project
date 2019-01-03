class PeriodicTable::Menu
  attr_accessor :key, :command, :function
  @@all = []

  def initialize(hash)
    prop_hash.each do |key, value|
      self.send("#{key}=", value)
    end
    save
  end

  def save
    @@all << self
  end

  def self.all
    @@all
  end
end
