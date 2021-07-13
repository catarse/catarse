# frozen_string_literal: true

namespace :balance_transfer do
  desc 'process transfers that is authorized'
  task process_authorized: :environment do
    PagarMe.api_key = CatarseSettings[:pagarme_api_key]
    BalanceTransfer.authorized.each do |bt|
      begin
        Rails.logger.info "[BalanceTransfer] processing -> #{bt.id} "

        bt.pagarme_delegator.transfer_funds
        bt.reload

        Rails.logger.info "[BalanceTransfer] processed to -> #{bt.transfer_id}"
        Rails.logger.info "Sleeping 1 second"
        sleep 1
      rescue Exception => e
        Sentry.capture_exception(e, user: { balance_transfer_id: bt.id })
        Rails.logger.info "[BalanceTransfer] processing gateway error on -> #{bt.id} "
        Rails.logger.info "[BalanceTransfer] processing gateway error message -> #{e.message} "

        bt.transition_to!(:gateway_error, { error_msg: e.message, error: e.to_json })

        if e.message == 'Idempotency-Key must be unique'
          Rails.logger.info '[BalanceTransfer] Trying to find transfer on last 30 transfers on PagarMe'

          PagarMe::Transfer.all(count: 30).each do |transfer|
            if bt.id.to_s == transfer.metadata&.balance_transfer_id.to_s
              Rails.logger.info "[BalanceTransfer] Transfer found: #{transfer.id}"
              Rails.logger.info transfer.to_hash
            end
          end
        end

        Rails.logger.info "Sleeping 1 second"
        sleep 1
      end
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
        Sentry.capture_exception(e, extra: { task: :update_status })
        return
      end

      retries += 1
      sleep 3
      retry
    rescue StandardError => e
      Sentry.capture_exception(e, extra: { task: :update_status })
    end

    BalanceTransfer.processing.where.not(transfer_id: nil).find_each do |bt|
      balance_transfer_processing(bt)
    end
  end
end
