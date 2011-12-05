class UsersMailer < ActionMailer::Base
  def notification_email(notification)
    @notification = notification
    old_locale = I18n.locale
    I18n.locale = @notification.user.locale
    mail(:from => "Catarse <contato@catarse.me>", :to => @notification.user.email, :subject => @notification.email_subject)
    I18n.locale = old_locale
  end
end
