class UsersMailer < ActionMailer::Base
  def notification_email(notification)
    @notification = notification
    old_locale = I18n.locale
    I18n.locale = @notification.user.locale
    mail(:from => "#{I18n.t('site.name')} <#{I18n.t('site.email.contact')}>", :to => @notification.user.email, :subject => @notification.email_subject)
    I18n.locale = old_locale
  end
end
