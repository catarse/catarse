class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :notification_type
  belongs_to :backer
  validates_presence_of :user, :text
  scope :not_dismissed, where(dismissed: false)
  attr_accessor :mail_params

  def self.create_notification_once(notification_type_name, user, filter, mail_params = {})
    create_notification(notification_type_name, user, mail_params) if self.where(filter.keys.first => filter.values.first, notification_type_id: find_notification(notification_type_name)).empty?
  end

  def self.create_notification(notification_type_name, user, mail_params = {})
    if (nt = find_notification notification_type_name)
      create! user: user,
        project: (mail_params[:project].nil? ? nil : mail_params[:project]),
        backer: (mail_params[:backer].nil? ? nil : mail_params[:backer]),
        notification_type: nt,
        mail_params: mail_params,
        text: 'this will be removed'
    end
  end

  def send_email
    unless dismissed
      self.update_attributes dismissed: true
      NotificationsMailer.notify(self).deliver
    end
  end

  protected
  def self.find_notification notification_type_name
    NotificationType.where(name: notification_type_name.to_s).first
  end
end
