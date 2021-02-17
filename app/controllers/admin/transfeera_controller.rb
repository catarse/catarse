# frozen_string_literal: true

module Admin
  class TransfeeraController < ApplicationController
    skip_before_action :verify_authenticity_token

    def webhook
      if transfeera_signature
        if valid_signature?
          update_balance_transfer
          render json: { success: 'ok' }
        else
          render json: { error: 'Invalid Signature' }, status: :not_acceptable
        end
      else
        render json: { success: 'ok' }
      end
    end

    private

    def valid_signature?
      Transfeera::Webhook.validate_request(transfeera_signature, request_body_json)
    end

    def transfeera_signature
      request.headers['Transfeera-Signature']
    end

    def request_body_json
      JSON.generate(transfeera_parameters)
    end

    def update_balance_transfer
      transfeera_transfer_data = transfeera_parameters['data']
      status = transfeera_transfer_data['status']
      transfer_id = transfeera_transfer_data['integration_id'].to_i
      transfer = BalanceTransfer.find transfer_id
      if transfer.present?
        try_update_to_error(transfer, status)
        try_update_to_transferred(transfer, status)
      end
    rescue StandardError => e
      Sentry.capture_exception(e)
    end

    def transfeera_parameters
      request.request_parameters[:transfeera]
    end

    def try_update_to_error(transfer, status)
      return unless transfer.state != :error && status == 'DEVOLVIDO'

      transfer.transition_to!(:error, transfeera_parameters)
    end

    def try_update_to_transferred(transfer, status)
      return unless transfer.state != :transferred && status == 'FINALIZADO'

      transfer.transition_to!(:transferred, transfeera_parameters)
    end
  end
end
