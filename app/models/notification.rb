class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :notification_type
  validates_presence_of :user, :text
  scope :not_dismissed, where(:dismissed => false)

  def send_email
    return unless self.email_subject and self.email_text and self.user.email
    NotificationsMailer.notify(self).deliver
  rescue
  end
end
