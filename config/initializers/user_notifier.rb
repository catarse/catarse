UserNotifier.configure do |config|
  # The system email will be used in all 'from' fields in your emails
  # This avoids issues with the sender autenticity, 
  # we always use the reply_to to set a return address
  config.system_email     = CatarseSettings.get_without_cache(:email_system)

  # The name of the email template in your views/layouts
  config.email_layout     = 'email'

  # The class name of your model representing system users that will receive the notifications
  # The model should have an email attribute containing the email address of the user
  config.user_class_name  = 'User'

  # This is the default email for reply_to 
  # in case the notification does not have a variable from_email
  config.from_email       = CatarseSettings.get_without_cache(:email_contact)

  # This is the default name used in from and reply_to 
  # in case the notification does not have a variable from_name
  config.from_name        = CatarseSettings.get_without_cache(:company_name)

  #Use sendgrid xsmptp API
  config.use_xsmtp_api = true

  #Don't deliver automatic notifications
  config.auto_deliver = false
end

