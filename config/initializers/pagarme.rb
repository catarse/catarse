CatarsePagarme.configure do |config|
  config.api_key = CatarseSettings.get_without_cache(:pagarme_api_key)
  config.slip_tax = CatarseSettings.get_without_cache(:pagarme_slip_tax)
  config.credit_card_tax = CatarseSettings.get_without_cache(:pagarme_credit_card_tax)
  config.interest_rate = CatarseSettings.get_without_cache(:pagarme_interest_rate)
  config.credit_card_cents_fee = CatarseSettings.get_without_cache(:pagarme_cents_fee)
  config.host = CatarseSettings.get_without_cache(:host)
  config.subdomain = 'www'
  config.protocol = 'http'
end
