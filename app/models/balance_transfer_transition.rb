class BalanceTransferTransition < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordTransition


  belongs_to :balance_transfer, inverse_of: :balance_transfer_transitions
end
