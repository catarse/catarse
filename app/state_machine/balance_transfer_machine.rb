# frozen_string_literal: true

class BalanceTransferMachine
  include Statesman::Machine

  state :pending, initial: true
  state :authorized
  state :processing
  state :transferred
  state :error
  state :gateway_error
  state :rejected

  transition from: :pending, to: %i[authorized rejected gateway_error]
  transition from: :authorized, to: %i[gateway_error error rejected processing pending]
  transition from: :processing, to: %i[error transferred gateway_error]
  transition from: :gateway_error, to: %i[processing transferred error]

  after_transition(from: :processing, to: :transferred) do |bt|
    if bt.project.present?
      bt.project.notify(:project_balance_transferred, bt.project.user, bt.project)
    end
  end

  after_transition(to: :error) do |bt|
    Notification.notify(:balance_transfer_error, bt.user, {
      balance_transfer_id: bt.id })
    bt.refund_balance
  end

  after_transition(to: :rejected) do |bt|
    Notification.notify(:balance_transfer_error, bt.user, {
      balance_transfer_id: bt.id })
    bt.refund_balance
  end
end
