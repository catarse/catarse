class FlexibleProjectMachine
  include Statesman::Machine
  BASIC_VALIDATION_STATES = %i(online waiting_funds successful).freeze

  state :draft, initial: true
  state :rejected
  state :online
  state :successful
  state :waiting_funds
  state :deleted

  transition from: :draft, to: [:rejected, :deleted, :online]
  transition from: :rejected, to: [:draft, :deleted]
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
  before_transition do |project, transition|
    transition.metadata[:from_state] = project.state
    project.state = transition.to_state
  end

  # After transition to successful should notify_observers
  after_transition to: :successful do |project| 
    project.notify_observers :sync_with_mailchimp
  end

  # After transition run, persist the current state
  # into model.state field.
  after_transition do |project, transition|
    project.save
    from_state = transition.metadata["from_state"]

    project.notify_observers :"from_#{from_state}_to_#{transition.to_state}"
  end

  # put project into draft state
  def push_to_draft
    transition_to :draft
  end

  # put project in rejected state
  def reject
    transition_to :rejected
  end


  # put project in online state
  def push_to_online
    transition_to :online
  end

  # put project in successful or waiting_funds state
  def finish
    transition_to(:successful) unless transition_to(:waiting_funds)
  end
end
