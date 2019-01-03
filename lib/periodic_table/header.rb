class PeriodicTable::Header
  attr_accessor :key, :title, :description, :length, :search_type
  @@all = []

  def initialize(hash)
    hash.each do |key, value|
      self.send("#{key}=", value)
    end
    save
  end

  def self.search_by_key(key)
    @all.detect{|header| header.key == key}
  end

  def save
    @@all << self
  end

  def self.all
    @@all
  end
end
