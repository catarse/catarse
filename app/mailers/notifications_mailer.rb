class NotificationsMailer < ActionMailer::Base
  layout 'email'

  def notify(notification)
    @notification = notification
    old_locale = I18n.locale
    I18n.locale = @notification.user.locale if I18n.locale.to_s != @notification.user.locale.to_s # we need this if to avoid stack overflow in controller
    mail({
      :from => "#{I18n.t('site.name')} <#{I18n.t('site.email.contact')}>", 
      :to => @notification.user.email, 
      :subject => @notification.email_subject
    })
    I18n.locale = old_locale if I18n.locale.to_s != @notification.user.locale.to_s
  end
end
