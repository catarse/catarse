module CatarsePagarme
  class Configuration
    attr_accessor :api_key, :konduto_api_key, :slip_tax, :credit_card_tax, :interest_rate, :host, :subdomain, :protocol,
      :max_installments, :minimum_value_for_installment, :credit_card_cents_fee, :pagarme_tax, :stone_tax,
      :stone_installment_tax, :cielo_tax, :cielo_installment_diners_tax, :cielo_installment_not_diners_tax,
      :cielo_installment_amex_tax, :cielo_installment_not_amex_tax, :ecr_key, :slip_week_day_interval, :antifraud_tax, :use_simility

    def initialize
      self.api_key = ''
      self.konduto_api_key = ''
      self.ecr_key = ''
      self.slip_tax = 0
      self.credit_card_tax = 0
      self.antifraud_tax = 0
      self.interest_rate = 0
      self.max_installments = 12
      self.minimum_value_for_installment = 10
      self.credit_card_cents_fee = 0
      self.host = 'catarse.me'
      self.subdomain = 'www'
      self.protocol = 'http'
      self.pagarme_tax = 0
      self.stone_tax = 0
      self.stone_installment_tax = 0
      self.cielo_tax = 0
      self.cielo_installment_diners_tax = 0
      self.cielo_installment_not_diners_tax = 0
      self.cielo_installment_amex_tax = 0
      self.cielo_installment_not_amex_tax = 0
      self.slip_week_day_interval = 2
      self.use_simility = true
    end
  end
end
