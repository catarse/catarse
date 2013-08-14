class Unsubscribe < ActiveRecord::Base
  schema_associations

  attr_accessor :subscribed

  def self.updates_unsubscribe project_id
    notification_type ||= NotificationType.where(name: 'updates').first
    self.find_or_initialize_by_project_id_and_notification_type_id(project_id, notification_type.id) if notification_type
  end
end
