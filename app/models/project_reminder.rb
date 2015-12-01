class ProjectReminder < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  validates :user_id, uniqueness: { scope: :project_id }
  validates :user_id, :project_id, presence: true

  scope :can_deliver, -> { where("project_reminders.can_deliver") }
end
