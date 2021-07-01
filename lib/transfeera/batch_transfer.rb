# frozen_string_literal: true

require 'net/http'

module Transfeera
  class BatchTransfer < BasePaymentRequest
    def self.create(catarse_transfers)
      http_request = HttpRequest.new
      BatchTransfer.new(http_request, Webhook.new(http_request)).create catarse_transfers
    end

    def self.remove(batch_id)
      http_request = HttpRequest.new
      BatchTransfer.new(http_request, Webhook.new(http_request)).remove batch_id
    end

    def initialize(http_request, webhook)
      super(http_request)
      @webhook = webhook
    end

    def create(catarse_transfers)
      webhook.update
      batch_with_transfers = map_catarse_to_transfeera_transfers(catarse_transfers)
      with_options = { method: 'POST', url: transfeera_batch_api_url, data: batch_with_transfers }
      batch_response = authorized_request with_options
      batch_id = batch_response['id']
      error_raiser batch_response if batch_id.nil?

      batch_id
    end

    def error_raiser(batch_response)
      message = batch_response['message']
      error_code = batch_response['errorCode']
      raise "#{message}. CODE: #{error_code}" if message.present? || error_code.present?

      raise "Batch transfer not created #{batch_response.inspect}"
    end

    def map_catarse_to_transfeera_transfers(catarse_transfers)
      transfeera_transfers = catarse_transfers.map do |transfer|
        bank_account = transfer.metadata.transform_keys(&:to_sym)
        catarse_account_type = bank_account[:bank_account_type]

        account_type = map_catarse_to_transfeera_account_type catarse_account_type
        create_transfer_hash transfer, bank_account, account_type
      end

      {
        name: Time.now.utc.to_s,
        transfers: transfeera_transfers
      }
    end

    def remove(batch_id)
      with_options = {
        method: 'DELETE',
        url: "#{transfeera_batch_api_url}/#{batch_id}"
      }

      authorized_request with_options
    end

    private

    def map_catarse_to_transfeera_account_type(catarse_account_type)
      if catarse_account_type.include?('conta_facil')
        'CONTA_FACIL'
      elsif catarse_account_type.include?('conta_corrente')
        'CONTA_CORRENTE'
      elsif catarse_account_type.include?('conta_poupanca')
        'CONTA_POUPANCA'
      end
    end

    def create_transfer_hash(transfer, bank_account, account_type)
      {
        value: (transfer.amount || 0).round(2),
        integration_id: transfer.id,
        payment_method: 'PIX',
        destination_bank_account: create_bank_account_hash(bank_account, account_type)
      }
    end

    def create_bank_account_hash(bank_account, account_type)
      {
        name: bank_account[:name],
        cpf_cnpj: bank_account[:document_number],
        bank_code: bank_account[:bank_code].to_i,
        agency: bank_account[:agency],
        agency_digit: bank_account[:agency_digit],
        account: bank_account[:account],
        account_digit: bank_account[:account_digit],
        account_type: account_type
      }
    end

    attr_reader :webhook

    def transfeera_batch_api_url
      "#{transfeera_api_url}/batch"
    end
  end
end
