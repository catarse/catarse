# frozen_string_literal: true

module Transfeera
  class BasePaymentRequest < BaseRequest
    def client_credentials
      options = {
        method: 'POST',
        url: transfeera_login_url,
        data: {
          grant_type: 'client_credentials',
          client_id: transfeera_payment_client_id,
          client_secret: transfeera_payment_client_secret
        }
      }

      request_json_with options
    end

    def transfeera_payment_client_id
      CatarseSettings.get_without_cache(:transfeera_payment_client_id)
    end

    def transfeera_payment_client_secret
      CatarseSettings.get_without_cache(:transfeera_payment_client_secret)
    end
  end
end
