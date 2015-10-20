class FlexibleProjectMachine
  include Statesman::Machine

  state :draft, initial: true
  state :in_analysis
  state :rejected
  state :approved
  state :online
  state :successful
  state :waiting_funds
  state :deleted

end
