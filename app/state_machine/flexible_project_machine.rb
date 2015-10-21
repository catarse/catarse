class FlexibleProjectMachine
  include Statesman::Machine
  BASIC_VALIDATION_STATES = %i(in_analysis approved online waiting_funds successful).freeze

  state :draft, initial: true
  state :in_analysis
  state :rejected
  state :approved
  state :online
  state :successful
  state :waiting_funds
  state :deleted

  transition from: :draft, to: [:in_analysis, :rejected, :deleted]
  transition from: :in_analysis, to: [:approved, :rejected, :deleted, :draft]
  transition from: :rejected, to: [:draft, :deleted]
  transition from: :approved, to: [:online, :in_analysis]
  transition from: :online, to: [:waiting_funds, :successful]
  transition from: :waiting_funds, to: [:successful]

  # Ensure that project is valid when try change
  # the project state
  guard_transition(to: BASIC_VALIDATION_STATES) do |project|
    project.valid?
  end

  # Ensure that project already expired to enter on waiting_funds or successful
  guard_transition(to: %i(waiting_funds successful)) do |project|
    project.expired?
  end

  # Ensure that project has pending contributions before enter on waiting_funds
  guard_transition(to: :waiting_funds) do |project|
    project.in_time_to_wait?
  end

  # Ensure that project has not more pending contributions
  # before enter on sucessful
  guard_transition(to: :successful) do |project|
    !project.in_time_to_wait?
  end

  # Before transition, change the state to trigger validations
  before_transition do |model, transition|
    model.state = transition.to_state
  end

  # After transition run, persist the current state
  # into model.state field.
  after_transition do |model, transition|
    model.save
  end

end
