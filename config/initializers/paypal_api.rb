ActiveMerchant::Billing::Base.mode = :test unless Rails.env.production?

unless Rails.env.test?
  PaypalApi.configure do |config|
    config.username = Configuration[:paypal_username]
    config.password = Configuration[:paypal_password]
    config.signature = Configuration[:paypal_signature]
  end
else
  Configuration.create!(name: "paypal_username", value: "usertest_api1.teste.com")
  Configuration.create!(name: "paypal_password", value: "HVN4PQBGZMHKFVGW")
  Configuration.create!(name: "paypal_signature", value: "AeL-u-Ox.N6Jennvu1G3BcdiTJxQAWdQcjdpLTB9ZaP0-Xuf-U0EQtnS")
end

if Configuration[:paypal_username] and Configuration[:paypal_password] and Configuration[:paypal_signature]
  EXPRESS_GATEWAY = ActiveMerchant::Billing::PaypalExpressGateway.new({
    login: Configuration[:paypal_username],
    password: Configuration[:paypal_password],
    signature: Configuration[:paypal_signature]
  })
else
  puts "[PayPal] An API Certificate or API Signature is required to make requests to PayPal"
end
