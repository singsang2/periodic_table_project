class PeriodicTable::Elements
  attr_accessor :symbol, :name, :Z, :atomic_weight, :url, :group, :period, :name_origin, :properties, :atomic
  @@all = []
  def initialize(hash_data)
    hash_data.each do |key, value|
      self.send("#{key}=", value)
    end
    save
  end

  #Relate element object with properties object
  def properties=(properties)
    @properties = properties
    @properties.element = self
  end

  def save
    @@all << self
  end

  def self.all
    @@all
  end
end
