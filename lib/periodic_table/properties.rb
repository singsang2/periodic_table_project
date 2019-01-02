class PeriodicTable::Properties
  attr_accessor :appearance, :block, :summary, :melting, :boiling, :phase, :density, :oxidation, :element
  @@all = []

  def initialize(prop_hash)
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
