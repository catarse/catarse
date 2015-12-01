class ProjectReminder < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  validates :user_id, uniqueness: { scope: :project_id }
  validates :user_id, :project_id, presence: true
end
