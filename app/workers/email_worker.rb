class EmailWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform notification_id
    resource = Notification.find notification_id

    # We don't want to raise exceptions in case our notification does not exist in the database
    if resource
      resource.update_attribute :sent_at, DateTime.now
      resource.deliver_without_worker
    else
      raise "Notification #{notification_id} not found.. sending to retry queue"
    end
  end
end
