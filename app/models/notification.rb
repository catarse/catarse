class Notification < ActiveRecord::Base
  schema_associations
  belongs_to :project_update, class_name: "Update", foreign_key: :update_id # Update was an unfortunate decision, we should rename it soon

  validates_presence_of :user

  def self.notify_once(template_name, user, filter, params = {})
    notify(template_name, user, params) if filter.nil? || self.where(filter.merge(template_name: template_name)).empty?
  end

  def self.notify(template_name, user, params = {})
    create!({
      template_name: template_name, 
      user: user,
      locale: user.locale || I18n.locale,
      origin_email: Configuration[:email_contact],
      origin_name: Configuration[:company_name]
    }.merge(params)).send_email
  end

  def send_email
    unless dismissed
      NotificationsMailer.notify(self).deliver
      self.update_attributes dismissed: true
    end
  end
end
