class Notification < ActiveRecord::Base
  schema_associations
  belongs_to :notification_type # don't know why schema_association did not get it. the FK seems to be in place
  belongs_to :project_update, class_name: "Update", foreign_key: :update_id # Update was an unfortunate decision, we should rename it soon

  validates_presence_of :user
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
      begin
        NotificationsMailer.notify(self).deliver
        self.update_attributes dismissed: true
      rescue Exception => e
        Rails.logger.error "Error while delivering email (#{e}).\n
        Check your configurations sendgrid and sendgrid_user_name\n
        Your notification was stored in the database with dismissed field set to false"
      end
    end
  end

  protected
  def self.find_notification notification_type_name
    NotificationType.where(name: notification_type_name.to_s).first
  end
end
