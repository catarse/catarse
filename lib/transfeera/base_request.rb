# frozen_string_literal: true

module Transfeera
  class BaseRequest
    def initialize(http_request)
      @http_request = http_request
    end

    protected

    def authorized_request(request_options)
      credentials = client_credentials
      access_token = credentials['access_token']

      headers = request_options.fetch(:headers, {})
      headers['Authorization'] = access_token
      headers['User-Agent'] = "Company (#{email_contact})"
      request_options[:headers] = headers

      request_json_with request_options
    end

    def client_credentials
      options = {
        method: 'POST',
        url: transfeera_login_url,
        data: {
          grant_type: 'client_credentials',
          client_id: transfeera_client_id,
          client_secret: transfeera_client_secret
        }
      }

      request_json_with options
    end

    def request_json_with(request_options)
      headers = request_options.fetch(:headers, {})
      headers['Content-Type'] = 'application/json'
      request_options[:headers] = headers
      request_options[:data] = request_options.fetch(:data, {}).to_json

      result = @http_request.execute request_options
      return JSON.parse(result.body) unless result.body.nil?
    end

    def transfeera_login_url
      @transfeera_login_url = CatarseSettings.get_without_cache(:transfeera_login_url)
    end

    def transfeera_client_id
      CatarseSettings.get_without_cache(:transfeera_client_id)
    end

    def transfeera_client_secret
      CatarseSettings.get_without_cache(:transfeera_client_secret)
    end

    def email_contact
      CatarseSettings.get_without_cache(:email_contact)
    end

    def transfeera_api_url
      @transfeera_api_url ||= CatarseSettings.get_without_cache(:transfeera_api_url)
    end
  end
end
