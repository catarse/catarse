class Channel::Profile < ActiveRecord::Base
  attr_accessible :description, :name, :permalink

  validates_presence_of :name, :description, :permalink
  validates_uniqueness_of :permalink


  # Links to channels should be their permalink
  def to_param; self.permalink end
end
