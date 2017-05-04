class BalanceTransferMachine
  include Statesman::Machine

  state :pending, initial: true
  state :authorized
  state :processing
  state :transferred
  state :error
  state :gateway_error
  state :rejected

  transition from: :pending, to: %i(authorized rejected)
  transition from: :authorized, to: %i(gateway_error error rejected processing pending)
  transition from: :processing, to: %i(error transferred)
  transition from: :gateway_error, to: %i(processing transferred error)

  after_transition(from: :pending, to: :authorized) do |bt|
    #bt.pagarme_delegator.transfer_funds
    # TODO: should refresh giving another balance transaction if has diff
    #bt.refresh_project_amount if bt.project && bt.project_amount_changed?
  end

  after_transition(from: :processing, to: :transferred) do |bt| 
    if bt.project.present?
      bt.project.notify(:project_balance_transferred, bt.project.user, bt.project)
    end
  end

  after_transition(to: :error) do |bt| 
    bt.refund_balance
  end

  after_transition(to: :rejected) do |bt|
    bt.refund_balance
  end
end
