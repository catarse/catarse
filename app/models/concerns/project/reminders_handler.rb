module Project::RemindersHandler
  extend ActiveSupport::Concern

  included do
    def user_already_in_reminder?(user_id)
      notifications.where(template_name: 'reminder', user_id: user_id).present?
    end
  end
end
