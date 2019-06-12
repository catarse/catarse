# frozen_string_literal: true

namespace :balance_transfer do
  desc 'process transfers that is authorized'
  task process_authorized: :environment do
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
    BalanceTransfer.processing.find_each do |bt|
      transfer = PagarMe::Transfer.find bt.transfer_id

      case transfer.status
      when 'transferred' then
        Rails.logger.info "[BalanceTransfer] #{bt.id} -> transferred"
        bt.transition_to(:transferred, transfer_data: transfer.to_hash)
      when 'failed', 'canceled' then
        Rails.logger.info "[BalanceTransfer] #{bt.id} -> failed"
        bt.transition_to(:error, transfer_data: transfer.to_hash)
      end
    end
  end
end
