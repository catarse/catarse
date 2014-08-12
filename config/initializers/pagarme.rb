CatarsePagarme.configure do |config|
  config.api_key = CatarseSettings[:pagarme_api_key]
  slip_tax = CatarseSettings[:pagarme_slip_tax]
end
