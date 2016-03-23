class BalanceTransferMachine
  include Statesman::Machine

  state :pending, initial: true
  state :authorized
  state :processing
  state :transferred
  state :error
  state :rejected

  transition from: :pending, to: %i(authorized rejected)

  after_transition(from: :pending, to: :authorized) do |bt|
    bt.pagarme_delegator.transfer_funds
  end
end
