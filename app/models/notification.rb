class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :notification_type
  belongs_to :backer
  validates_presence_of :user, :text
  scope :not_dismissed, where(:dismissed => false)
  attr_accessor :mail_params

  def self.find_notification notification_type_name
    nt = NotificationType.where(:name => notification_type_name.to_s).first
    raise "There is no NotificationType with name #{notification_type_name}" unless nt
    return nt
  end

  def self.create_notification(notification_type_name, user, mail_params = {})
    create! :user => user, :project => (mail_params[:project].nil? ? nil : mail_params[:project]), :backer => (mail_params[:backer].nil? ? nil : mail_params[:backer]), :notification_type => (find_notification notification_type_name), :mail_params => mail_params, :text => 'this will be removed'
  end

  def send_email
    unless dismissed
      self.update_attributes :dismissed => true
      NotificationsMailer.notify(self).deliver
    end
  end
end
