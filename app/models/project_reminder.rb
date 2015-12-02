class ProjectReminder < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  validates :user_id, uniqueness: { scope: :project_id }
  validates :user_id, :project_id, presence: true

  scope :can_deliver, -> {
    where("project_reminders.can_deliver") }

  scope :without_notification, -> {
statement = <<-SQL
not exists(
select true from project_notifications pn
where pn.user_id = project_reminders.user_id
and pn.project_id = project_reminders.project_id
and template_name = 'reminder'
)
SQL
    where(statement)
  }
end
