class State < ActiveRecord::Base
  validates_presence_of :name, :acronym
  validates_uniqueness_of :name, :acronym
  def self.array
    return @array if @array
    @array = []
    self.order(:name).all.each do |state|
      @array << [state.name, state.acronym]
    end
    @array
  end
end

# == Schema Information
#
# Table name: states
#
#  id         :integer         not null, primary key
#  name       :string(255)     not null
#  acronym    :string(255)     not null
#  created_at :datetime
#  updated_at :datetime
#

