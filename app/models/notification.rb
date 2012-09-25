class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  validates_presence_of :user, :text
  scope :not_dismissed, where(:dismissed => false)

  def send_email
    unless dismissed
      return unless self.email_subject and self.email_text and self.user.email
      self.update_attributes :dismissed => true
      UsersMailer.notification_email(self).deliver
    end
  rescue
  end
end
