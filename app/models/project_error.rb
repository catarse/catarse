class ProjectError < ActiveRecord::Base
  belongs_to :project

  validates :error, :to_state, presence: true
end

