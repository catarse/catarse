class ProjectBudget < ActiveRecord::Base
  belongs_to :project

  validates :name, :value, presence: true
end
