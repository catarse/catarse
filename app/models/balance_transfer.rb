class BalanceTransfer < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  has_many :transitions,
    class_name: 'BalanceTransferTransition',
    autosave: false

  scope :processing, -> () {
    where("balance_transfers.current_state = 'processing'")
  }

  delegate :can_transition_to?, :transition_to, to: :state_machine

  def state_machine
    @stat_machine ||= BalanceTransferMachine.new(self, {
      transition_class: 'BalanceTransferTransition',
      association_name: :transitions
    })
  end

  def state
    state_machine.current_state || 'pending'
  end

  %w(pending authorized processing transferred error rejected).each do |st|
    define_method "#{st}?" do
      self.state == st
    end
  end
end
