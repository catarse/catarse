class Unsubscribe < ActiveRecord::Base
  belongs_to :user
  belongs_to :notification_type
  belongs_to :project

  attr_accessor :subscribed

  def self.updates_unsubscribe project_id
    @notification_type ||= NotificationType.where(name: 'updates').first
    self.find_or_initialize_by_project_id_and_notification_type_id(project_id, @notification_type.id) if @notification_type
  end
end
