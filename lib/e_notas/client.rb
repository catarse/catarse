# frozen_string_literal: true

module ENotas
  class Client
    include HTTParty

    base_uri 'https://app.enotas.com.br/api'

    def create_nfe(nfe_params)
      response = self.class.post('/vendas', headers: headers, body: nfe_params.to_json)
      unless response.success?
        error_options = { level: :fatal, extra: { data: response.parsed_response } }
        Sentry.capture_message('Error in creating invoice', error_options)
      end

      response.parsed_response
    end

    private

    def headers
      {
        'Authorization' => "Basic #{api_key}",
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    end

    def api_key
      return CatarseSettings.get_without_cache(:enotas_api_key) if Rails.env.production?

      CatarseSettings.get_without_cache(:enotas_test_api_key)
    end
  end
end
