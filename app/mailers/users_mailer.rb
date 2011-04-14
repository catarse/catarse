class UsersMailer < ActionMailer::Base
  default :from => "#{current_site.name} <#{current_site.email}>"
  def notification_email(notification)
    @notification = notification
    mail(:to => @notification.user.email, :subject => @notification.email_subject)
  end
end
