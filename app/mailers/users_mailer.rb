class UsersMailer < ActionMailer::Base
  def notification_email(notification)
    @notification = notification
    mail(:from => "\"#{@notification.site.name}\" <#{@notification.site.email}>", :to => @notification.user.email, :subject => @notification.email_subject)
  end
end
