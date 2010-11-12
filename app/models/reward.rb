class Reward < ActiveRecord::Base
  belongs_to :project
  has_many :backers
  validates_presence_of :project, :minimum_value, :maximum_backers, :description
  validates_numericality_of :minimum_value, :greater_than_or_equal_to => 1.00
  validates_numericality_of :maximum_backers, :only_integer => true, :greater_than_or_equal_to => 0
end

