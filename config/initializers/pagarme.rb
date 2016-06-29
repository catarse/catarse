CatarsePagarme.configure do |config|
  config.api_key = CatarseSettings.get_without_cache(:pagarme_api_key)
  config.ecr_key = CatarseSettings.get_without_cache(:pagarme_encryption_key)
  config.slip_tax = CatarseSettings.get_without_cache(:pagarme_slip_tax)
  config.credit_card_tax = CatarseSettings.get_without_cache(:pagarme_credit_card_tax)
  config.interest_rate = CatarseSettings.get_without_cache(:pagarme_interest_rate)
  config.credit_card_cents_fee = CatarseSettings.get_without_cache(:pagarme_cents_fee)
  config.host = CatarseSettings.get_without_cache(:host)
  config.subdomain = 'www'
  config.protocol = 'https'
  config.max_installments = CatarseSettings.get_without_cache(:pagarme_max_installments)
  config.minimum_value_for_installment = CatarseSettings.get_without_cache(:pagarme_minimum_value_for_installment)

  config.pagarme_tax = CatarseSettings.get_without_cache(:pagarme_tax)
  config.cielo_tax = CatarseSettings.get_without_cache(:cielo_tax)
  config.antifraud_tax = CatarseSettings.get_without_cache(:antifraud_tax)
  config.stone_tax = CatarseSettings.get_without_cache(:stone_tax)
  config.stone_installment_tax = CatarseSettings.get_without_cache(:stone_installment_tax)
  config.cielo_installment_diners_tax = CatarseSettings.get_without_cache(:cielo_installment_diners_tax)
  config.cielo_installment_not_diners_tax = CatarseSettings.get_without_cache(:cielo_installment_not_diners_tax)
  config.cielo_installment_amex_tax = CatarseSettings.get_without_cache(:cielo_installment_amex_tax)
  config.cielo_installment_not_amex_tax = CatarseSettings.get_without_cache(:cielo_installment_not_amex_tax)
end

