class State < ActiveRecord::Base
  validates_presence_of :name, :acronym
  validates_uniqueness_of :name, :acronym
  def self.array
    return @array if @array
    @array = []
    self.order(:name).each do |state|
      @array << [state.name, state.acronym]
    end
    @array.push(['Outro / Other', 'outro / other'])
    @array
  end
end
