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
  delegate :project_transfer, to: :project

  def refresh_project_amount
    update_attribute :amount, project_transfer.total_amount
  end

  def project_amount_changed?
    project_transfer.total_amount != amount
  end

  def state_machine
    @stat_machine ||= BalanceTransferMachine.new(self, {
      transition_class: BalanceTransferTransition,
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
