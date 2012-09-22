class NotificationsMailer < ActionMailer::Base
  layout 'email'

  def notify(notification)
    @notification = notification
    old_locale = I18n.locale
    I18n.locale = @notification.user.locale if I18n.locale.to_s != @notification.user.locale.to_s # we need this if to avoid stack overflow in controller
    if @notification.notification_type
      m = mail({
        :from => "#{I18n.t('site.name')} <#{I18n.t('site.email.contact')}>", 
        :to => @notification.user.email, 
        :subject => I18n.t("notifications.#{@notification.notification_type.name}.subject", :project => @notification.backer.project.name),
        :template_name => @notification.notification_type.name
      })
    else #TODO remove when we are done migrating the notifications
      m = mail({
        :from => "#{I18n.t('site.name')} <#{I18n.t('site.email.contact')}>", 
        :to => @notification.user.email, 
        :subject => @notification.email_subject
      })
    end
    I18n.locale = old_locale if I18n.locale.to_s != @notification.user.locale.to_s
  end
end
