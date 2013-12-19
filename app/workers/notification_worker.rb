class NotificationWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform notification_id
    resource = Notification.find_by id: notification_id
    # We don't want to raise exceptions in case our notification does not exist in the database
    if resource
      NotificationsMailer.notify(resource).deliver
      resource.update_attributes dismissed: true
    end
  end
end
