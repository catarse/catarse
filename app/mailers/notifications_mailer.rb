class NotificationsMailer < ActionMailer::Base
  layout 'email'

  def notify(notification)
    @notification = notification
    old_locale = I18n.locale
    I18n.locale = @notification.locale
    address = Mail::Address.new @notification.origin_email
    address.display_name = @notification.origin_name
    subject = render_to_string(template: "notifications_mailer/subjects/#{@notification.template_name}")
    m = mail({
      from: address.format,
      to: @notification.user.email,
      subject: subject,
      template_name: @notification.template_name
    })
    I18n.locale = old_locale
    m
  end
end
