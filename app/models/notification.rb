class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :notification_type
  belongs_to :backer
  validates_presence_of :user, :text
  scope :not_dismissed, where(:dismissed => false)

  def self.notify_backer backer, notification_type_name
    nt = NotificationType.where(:name => notification_type_name.to_s).first
    if nt
      create! :backer => backer, :user => backer.user, :email_text => 'this will be removed', :text => 'this will be removed', :notification_type_id => nt.id
    else
      raise "There is no NotificationType with name #{notification_type_name}"
    end
  end

  def send_email
    NotificationsMailer.notify(self).deliver
  end
end
