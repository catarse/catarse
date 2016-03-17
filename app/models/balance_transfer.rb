class BalanceTransfer < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  has_many :transitions,
    class_name: 'BalanceTransferTransition',
    autosave: false

  def state_machine
    @stat_machine ||= BalanceTransferMachine.new(self, {
      transition_class: 'BalanceTransferTransition',
      association_name: :transitions
    })
  end

  def state
    state_machine.current_state || 'pending'
  end

  %w(pending authorized processing transfered error rejected).each do |st|
    define_method "#{st}?" do
      self.state == st
    end
  end
end
