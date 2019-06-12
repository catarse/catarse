class BlacklistDocument < ActiveRecord::Base
  validates_uniqueness_of :number
  def number=(number)
    self[:number] = number.to_s.gsub(/[^0-9]*/, "")
  end

  def self.find_document(number)
    self.find_by("number = :number", {number: number.to_s.gsub(/[^0-9]*/, "")})
  end
end
