# frozen_string_literal: true

class BalanceTransferTransition < ActiveRecord::Base
  belongs_to :balance_transfer, inverse_of: :transitions

  def bank_account
    metadata.try(:[], 'transfer_data').try(:[], 'bank_account')
  end

  def skip_notification?
    metadata["skip_notification"]
  end
end
