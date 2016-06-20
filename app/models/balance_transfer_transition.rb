class BalanceTransferTransition < ActiveRecord::Base
  belongs_to :balance_transfer, inverse_of: :transitions
end
