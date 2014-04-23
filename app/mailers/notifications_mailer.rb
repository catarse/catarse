class NotificationsMailer < ActionMailer::Base
  layout 'email'

  def notify(notification)
    @notification = notification
    old_locale = I18n.locale
    I18n.locale = @notification.locale
    subject = render_to_string(template: "notifications_mailer/subjects/#{@notification.template_name}")
    m = mail({
      from: address_format(CatarseSettings[:email_system], @notification.origin_name),
      reply_to: address_format(@notification.origin_email, @notification.origin_name),
      to: @notification.user.email,
      subject: subject,
      template_name: @notification.template_name
    })
    I18n.locale = old_locale
    m
  end

  private
  def address_format email, name
    address = Mail::Address.new email
    address.display_name = name
    address.format
  end
end
