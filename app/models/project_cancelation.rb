class ProjectCancelation < ApplicationRecord
  belongs_to :project
  validates :project, presence: true
  validates :project_id, uniqueness: true
end
