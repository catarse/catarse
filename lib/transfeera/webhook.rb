# frozen_string_literal: true

module Transfeera
  class Webhook < BasePaymentRequest
    def self.validate_request(transfeera_signature, request_body)
      Webhook.new(HttpRequest.new).validate_request(transfeera_signature, request_body)
    end

    def validate_request(transfeera_signature, request_body_json)
      elements = transfeera_signature.split(',')

      timestamp = elements[0].split('=')[1]

      schema_v1_element = elements.detect { |e| e.split('=')[0] == 'v1' }
      schema_v1_signature = schema_v1_element.split('=')[1]

      message_to_create_hash = "#{timestamp}.#{request_body_json}"

      webhook_data = transfeera_webhook_data
      webhook_signature_secret = webhook_data['signature_secret']
      computed_hmac_sha256_signature = compute_hmac_sha256_hex(webhook_signature_secret, message_to_create_hash)
      schema_v1_signature == computed_hmac_sha256_signature
    end

    def compute_hmac_sha256_hex(secret, message)
      digest = OpenSSL::Digest.new('sha256')
      OpenSSL::HMAC.hexdigest(digest, secret, message)
    end

    def update
      api_webhook_data = fetch_api_webhook_data
      api_webhook_url = api_webhook_data.fetch('url', nil)
      if api_webhook_url.nil?
        create_webhook
      elsif api_webhook_url != transfeera_created_webhook_url
        update_webhook(api_webhook_data.fetch('id', nil))
      else
        api_webhook_data
      end
    end

    private

    def fetch_api_webhook_data
      with_options = {
        method: 'GET',
        url: transfeera_webhook_api_url
      }

      result = authorized_request with_options
      save_webhook_result result
    rescue StandardError => e
      Sentry.capture_exception(e)
      Rails.logger.info("Error getting Transfeera webhook: #{e.inspect}")
      {}
    end

    def create_webhook
      with_options = { method: 'POST', url: transfeera_webhook_api_url,
                       data: { url: transfeera_created_webhook_url, object_types: ['Transfer'] } }
      Rails.logger.info('Creating Transfeera-Catarse Webhook url...')
      authorized_request with_options
      fetch_api_webhook_data
    rescue StandardError => e
      Sentry.capture_exception(e)
      Rails.logger.info("Error creating Transfeera webhook: #{e.inspect}")
      nil
    end

    def update_webhook(webhook_id)
      Rails.logger.info('Updating Transfeera-Catarse Webhook url...')
      authorized_request(update_webhook_config(webhook_id))
      fetch_api_webhook_data
    rescue StandardError => e
      Sentry.capture_exception(e)
      Rails.logger.info("Error updating Transfeera webhook: #{e.inspect}")
      nil
    end

    def update_webhook_config(webhook_id)
      {
        method: 'PUT',
        url: "#{transfeera_webhook_api_url}/#{webhook_id}",
        data: {
          url: transfeera_created_webhook_url,
          object_types: ['Transfer']
        }
      }
    end

    def save_webhook_result(webhook_result)
      raise 'No webhook content' if webhook_result.empty?

      webhook_data_json = webhook_result[0].to_json
      CatarseSettings[:transfeera_webhook_data] = webhook_data_json
      webhook_result[0]
    rescue StandardError => e
      Sentry.capture_exception(e)
      Rails.logger.info("Error saving Transfeera webhook data to settings: #{e.inspect} #{webhook_result.inspect}")
      Rails.logger.info(e.backtrace)
      {}
    end

    def transfeera_webhook_data
      JSON.parse(CatarseSettings.get_without_cache(:transfeera_webhook_data)).to_h
    rescue StandardError => e
      Sentry.capture_exception(e)
      Rails.logger.info("Error parsing Transfeera webhook data from settings: #{e.inspect}")
      nil
    end

    def transfeera_webhook_api_url
      @transfeera_webhook_api_url ||= "#{transfeera_api_url}/webhook"
    end

    def transfeera_created_webhook_url
      @transfeera_created_webhook_url ||= CatarseSettings.get_without_cache(:transfeera_created_webhook_url)
    end
  end
end
