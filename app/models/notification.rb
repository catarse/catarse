class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :notification_type
  belongs_to :backer
  validates_presence_of :user, :text
  scope :not_dismissed, where(:dismissed => false)

  def self.find_notification notification_type_name
    nt = NotificationType.where(:name => notification_type_name.to_s).first
    raise "There is no NotificationType with name #{notification_type_name}" unless nt
    return nt
  end

  def self.notify_backer backer, notification_type_name
    nt = find_notification notification_type_name
    create! :project => backer.project, :backer => backer, :user => backer.user, :email_text => 'this will be removed', :text => 'this will be removed', :notification_type_id => nt.id
  end

  def self.notify_project_owner project, notification_type_name
    nt = find_notification notification_type_name
    create! :project => project, :user => project.user, :email_text => 'this will be removed', :text => 'this will be removed', :notification_type_id => nt.id
  end

  def self.notify_backer_project_successful backer, notification_type_name
    raise 'entroer'
    nt = find_notification notification_type_name
    create! :project => backer.project, :backer => backer, :user => backer.user, :email_text => 'this will be removed', :text => 'this will be removed', :notification_type_id => nt.id
  end

  def self.notify_backer_project_unsuccessful backer, notification_type_name
    nt = find_notification notification_type_name
    create! :project => backer.project, :backer => backer, :user => backer.user, :email_text => 'this will be removed', :text => 'this will be removed', :notification_type_id => nt.id
  end

  def send_email
    unless dismissed
      self.update_attributes :dismissed => true
      NotificationsMailer.notify(self).deliver
    end
  end
end
