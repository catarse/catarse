# frozen_string_literal: true

CatarsePagarme.configure do |config|
  config.api_key =  'foo'
  config.konduto_api_key = 'bar'
  config.slip_tax = 0
  config.credit_card_tax = 0
  config.interest_rate = 0
end
