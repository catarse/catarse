# frozen_string_literal: true

namespace :balance_transfer do
  desc 'process transfers that is authorized'
  task process_authorized: :environment do
    PagarMe.api_key = CatarseSettings[:pagarme_api_key]
    BalanceTransfer.authorized.each do |bt|
      Raven.user_context(balance_transfer_id: bt.id)

      begin
        Rails.logger.info "[BalanceTransfer] processing -> #{bt.id} "

        bt.pagarme_delegator.transfer_funds
        bt.reload

        Rails.logger.info "[BalanceTransfer] processed to -> #{bt.transfer_id}"
      rescue Exception => e
        Raven.capture_exception(e)
        Rails.logger.info "[BalanceTransfer] processing gateway error on -> #{bt.id} "

        bt.transition_to!(
          :gateway_error,
          { error_msg: e.message, error: e.to_json }
        )
      end

      Raven.user_context({})
    end
  end

  desc 'update balance_transfers status'
  task update_status: :environment do
    PagarMe.api_key = CatarseSettings[:pagarme_api_key]

    def balance_transfer_processing(bt)
      retries ||= 0
      transfer = PagarMe::Transfer.find bt.transfer_id

      case transfer.status
      when 'transferred' then
        Rails.logger.info "[BalanceTransfer] #{bt.id} -> transferred"
        bt.transition_to(:transferred, transfer_data: transfer.to_hash)
      when 'failed', 'canceled' then
        Rails.logger.info "[BalanceTransfer] #{bt.id} -> failed"
        bt.transition_to(:error, transfer_data: transfer.to_hash)
      end
    rescue RestClient::BadGateway => e
      if retries > 3
        Raven.extra_context(task: :update_status)
        Raven.capture_exception(e)
        return
      end

      retries += 1
      sleep 3
      retry
    rescue StandardError => e
      Raven.extra_context(task: :update_status)
      Raven.capture_exception(e)
    end

    BalanceTransfer.processing.each do |bt|
      balance_transfer_processing(bt)
    end
  end
end
