class City < ActiveRecord::Base
  belongs_to :state

  def show_name
    "#{self.name}, #{self.state.acronym}"
  end
end
