class Backer < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  validates_presence_of :project, :user, :value
  validates_numericality_of :value, :greater_than => 0
end

