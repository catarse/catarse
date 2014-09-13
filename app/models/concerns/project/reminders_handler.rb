module Project::RemindersHandler
  extend ActiveSupport::Concern

  included do
    def user_already_in_reminder?(user_id)
      notifications.where(template_name: 'reminder', user_id: user_id).present? ||
      user_in_reminder_queue?(user_id)
    end

    def user_in_reminder_queue?(user_id)
      scheduler_set.any? do |job|
        job['class'] == 'ReminderProjectWorker' &&
        job.args[0] == user_id &&
        job.args[1] == self.id
      end
    end

    def delete_from_reminder_queue(user_id)
      job = scheduler_set.select do |job|
        job['class'] == 'ReminderProjectWorker' &&
        job.args[0] == user_id &&
        job.args[1] == self.id
      end
      job.each(&:delete)
    end

    def scheduler_set
      @queue_set ||= Sidekiq::ScheduledSet.new
    end
  end
end
