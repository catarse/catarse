# frozen_string_literal: true

class BalanceTransferTransition < ActiveRecord::Base
  belongs_to :balance_transfer, inverse_of: :transitions
end
