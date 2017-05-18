class BalanceTransfer < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  has_many :balance_transactions

  has_many :transitions,
    class_name: 'BalanceTransferTransition',
    autosave: false

  scope :processing, -> () {
    where("balance_transfers.current_state = 'processing'")
  }

  scope :pending, -> () {
    where("balance_transfers.current_state = 'pending'")
  }

  scope :authorized, -> () {
    where("balance_transfers.current_state = 'authorized'")
  }

  delegate :can_transition_to?, :transition_to, :transition_to!, to: :state_machine

  def state_machine
    @stat_machine ||= BalanceTransferMachine.new(self, {
      transition_class: BalanceTransferTransition,
      association_name: :transitions
    })
  end

  def state
    state_machine.current_state || 'pending'
  end

  def refund_balance
    self.transaction do
      balance_transactions.create!(
        amount: amount,
        user_id: user_id,
        event_name: 'balance_transfer_error'
      )
    end
  end

  %w(pending authorized processing transferred error rejected).each do |st|
    define_method "#{st}?" do
      self.state == st
    end
  end

  def transfer_funds!
    begin
      Rails.logger.info "[BalanceTransfer] processing -> #{self.id} "
      Raven.user_context(balance_transfer_id: bt.id)
      self.pagarme_delegator.transfer_funds
      self.reload
      Rails.logger.info "[BalanceTransfer] processed to -> #{self.transfer_id}"
    rescue Exception => e
      Raven.capture_exception(e)
      Ranve.user_context({})
      Rails.logger.info "[BalanceTransfer] processing gateway error on -> #{self.id} "
      self.transition_to!(
        :gateway_error,
        { error_msg: e.message, error: e.to_h })
    end
  end

end
