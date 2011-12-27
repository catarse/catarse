unless Rails.env.test?
  PaypalApi.configure do |config|
    config.username = Configuration[:paypal_username]
    config.password = Configuration[:paypal_password]
    config.signature = Configuration[:paypal_signature]
  end
end