CatarsePagarme.configure do |config|
  config.api_key = CatarseSettings[:pagarme_api_key]
  config.slip_tax = CatarseSettings[:pagarme_slip_tax]
  config.credit_card_tax = CatarseSettings[:pagarme_credit_card_tax]
  config.interest_rate = CatarseSettings[:pagarme_interest_rate]
end
