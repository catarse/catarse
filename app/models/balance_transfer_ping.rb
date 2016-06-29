class BalanceTransferPing < ActiveRecord::Base
  belongs_to :balance_transfer
  serialize :metadata, JSON

  def ping
    pagarme_delegator.transfer_funds
  end

  %w(pending authorized processing transferred error rejected).each do |st|
    define_method "#{st}?" do
      self.state == st
    end
  end
end
