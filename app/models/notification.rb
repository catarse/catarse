class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :notification_type
  belongs_to :backer
  # Update was an unfortunate decision, we should rename it soon
  belongs_to :project_update, class_name: "Update", foreign_key: :update_id
  validates_presence_of :user
  scope :not_dismissed, where(dismissed: false)
  attr_accessor :mail_params

  def self.create_notification_once(notification_type_name, user, filter, mail_params = {})
    create_notification(notification_type_name, user, mail_params) if self.where(filter.merge(notification_type_id: find_notification(notification_type_name))).empty?
  end

  def self.create_notification(notification_type_name, user, mail_params = {})
    if (nt = find_notification notification_type_name)
      create! user: user,
        project: mail_params[:project],
        backer: mail_params[:backer],
        project_update: mail_params[:update],
        notification_type: nt,
        mail_params: mail_params
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
