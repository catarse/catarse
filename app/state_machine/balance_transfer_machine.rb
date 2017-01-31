class BalanceTransferMachine
  include Statesman::Machine

  state :pending, initial: true
  state :authorized
  state :processing
  state :transferred
  state :error
  state :rejected

  transition from: :pending, to: %i(authorized rejected)
  transition from: :authorized, to: %i(error rejected processing pending)
  transition from: :processing, to: %i(error transferred)
  transition from: :error, to: %i(authorized)

  after_transition(from: :pending, to: :authorized) do |bt|
    #bt.pagarme_delegator.transfer_funds
    bt.refresh_project_amount if bt.project_amount_changed?
  end

  after_transition(from: :processing, to: :transferred) do |bt| 
    if bt.project.present?
      bt.project.notify(:project_balance_transferred, bt.project.user, bt.project)
    end
  end
end
