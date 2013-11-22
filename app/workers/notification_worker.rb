class NotificationWorker
  include Sidekiq::Worker
  sidekiq_options retry: true

  def perform notification_id
    resource = Notification.find notification_id

    NotificationsMailer.notify(resource).deliver

    resource.update_attributes dismissed: true
  end
end
