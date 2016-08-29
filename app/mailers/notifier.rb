class Notifier < ActionMailer::Base
  default template_path:'user_notifier/mailer/'
  layout UserNotifier.email_layout

  def notify(notification)
    @notification = notification

    I18n.with_locale @notification.locale do
      configure_xsmtp_headers if UserNotifier.use_xsmtp_api
      mail(mail_attributes)
    end
  end

  private

  def subject
    render_to_string(template: "user_notifier/mailer/#{@notification.template_name}_subject")
  end

  def mail_attributes
    {
      from: address_format(UserNotifier.system_email, @notification.from_name),
      reply_to: address_format(@notification.from_email, @notification.from_name),
      to: (@notification.user.try(:email) || @notification.user_email),
      subject: subject,
      template_name: @notification.template_name
    }
  end

  def configure_xsmtp_headers
    headers['X-SMTPAPI'] = {
      unique_args: {
        notification_user: @notification.user_id,
        notification_type: @notification.class.to_s,
        notification_id: @notification.id,
        template_name: @notification.template_name
      }
    }.to_json
  end

  def address_format email, name
    address = Mail::Address.new email
    address.display_name = name
    address.format
  end
end
