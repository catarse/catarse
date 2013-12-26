class NotificationWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform notification_id
    resource = Notification.find_by id: notification_id
    # We don't want to raise exceptions in case our notification does not exist in the database
    if resource
      NotificationsMailer.notify(resource).deliver
      resource.update_attributes dismissed: true
    else
      raise "Notification #{notification_id} not found.. sending to retry queue"
    end
  end
end
