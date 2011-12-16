begin
  unless Rails.env == 'test'
    PaypalApi.configure do |config|
      config.username   = Configuration.find_by_name('paypal_username').value
      config.password   = Configuration.find_by_name('paypal_password').value
      config.signature  = Configuration.find_by_name('paypal_signature').value
    end
  end
rescue
end