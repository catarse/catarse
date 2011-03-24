class UsersMailer < ActionMailer::Base
  default :from => "Catarse <contato@catarse.me>"
  def notification_email(notification)
    @notification = notification
    mail(:to => @notification.user.email, :subject => @notification.email_subject)
  end
end
