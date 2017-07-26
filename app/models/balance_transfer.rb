# frozen_string_literal: true

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
    return unless %w(error rejected).include?(state)
    transaction do
      balance_transactions.create!(
        amount: amount,
        user_id: user_id,
        event_name: 'balance_transfer_error'
      ) unless balance_transactions.where(event_name: 'balance_transfer_error').exists?
    end
  end

  %w[pending authorized processing transferred error rejected].each do |st|
    define_method "#{st}?" do
      state == st
    end
  end

  def bank_data
    last_transition = state_machine.last_transition

    last_transition.bank_account || user.bank_account.to_hash_with_bank
  end

  def transfer_limit_date
    pluck_from_database("transfer_limit_date")
  end

  def pluck_from_database(attribute)
    BalanceTransfer.where(id: id).pluck("balance_transfers.#{attribute}").first
  end
end
