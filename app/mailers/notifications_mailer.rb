class NotificationsMailer < ActionMailer::Base
  layout 'email'

  def notify(notification)
    @notification = notification
    old_locale = I18n.locale
    I18n.locale = @notification.user.locale if I18n.locale.to_s != @notification.user.locale.to_s # we need this if to avoid stack overflow in controller
    from_email = ( @notification.mail_params && @notification.mail_params[:from] ) || I18n.t('site.email.contact')
    address = Mail::Address.new from_email
    address.display_name = I18n.t('site.name')
    subject = I18n.t("notifications.#{@notification.notification_type.name}.subject", @notification.mail_params)
    @header = I18n.t("notifications.#{@notification.notification_type.name}.header", @notification.mail_params, :default => subject)
    m = mail({
      :from => address.format,
      :to => @notification.user.email,
      :subject => subject,
      :template_name => @notification.notification_type.name
    })
    I18n.locale = old_locale if I18n.locale.to_s != @notification.user.locale.to_s
  end
end
