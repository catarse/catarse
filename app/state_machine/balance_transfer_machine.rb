class BalanceTransferMachine
  include Statesman::Machine

  state :pending, initial: true
  state :authorized
  state :processing
  state :transferred
  state :error
  state :rejected

  transition from: :pending, to: %i(authorized rejected)
  transition from: :authorized, to: %i(error rejected processing)
  transition from: :processing, to: %i(error transferred)

  after_transition(from: :pending, to: :authorized) do |bt|
    bt.pagarme_delegator.transfer_funds
    bt.project.notify(:project_balance_transferred, bt.project.user,bt.project) if bt.project.present?
  end
end
