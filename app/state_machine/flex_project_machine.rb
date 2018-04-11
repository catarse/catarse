# frozen_string_literal: true

class FlexProjectMachine
  include Statesman::Machine

  def self.basic_validation_states
    %i[online successful].freeze
  end

  def self.need_expiration_states
    %i[waiting_funds successful failed].freeze
  end

  def self.finished_states
    %i[successful failed].freeze
  end

  def self.setup_machine
    state :draft, initial: true
    state :rejected
    state :online
    state :successful
    state :failed
    state :waiting_funds
    state :deleted

    # this block receive all transition
    # definitions
    yield self if block_given?

    # Ensure that project is valid when try change
    # the project state
    guard_transition(to: basic_validation_states) do |project, t, m|
      # TODO: rething this
      to_state = m[:to_state].to_s
      project.state = to_state
      valid = project.valid?
      project.state = project.state_was

      if project.errors.present?
        # save errors on database
        project.errors.messages.each do |error|
          messages = error[1]
          messages.each do |message|
            project.project_errors.create(error: message, to_state: to_state)
          end
        end
      end
      valid || m[:skip_validation]
    end

    # Ensure that project already expired to enter on waiting_funds or successful
    guard_transition(to: need_expiration_states) do |project|
      project.expired?
    end

    # Ensure that project has pending contributions before enter on waiting_funds
    guard_transition(to: :waiting_funds) do |project|
      project.in_time_to_wait? && !project.project_cancelation.present?
    end

    guard_transition(to: finished_states) do |project|
      !project.in_time_to_wait? && !project.project_cancelation.present?
    end

    # Ensure that project has not more pending contributions
    guard_transition(to: :failed) do |project|
      project.is_a?(FlexibleProject) ? project.paid_pledged == 0 : true
    end

    guard_transition(to: :successful) do |project|
      project.is_a?(FlexibleProject) ? project.paid_pledged > 0 : true
    end

    # Before transition, change the state to trigger validations
    before_transition do |project, transition|
      transition.metadata[:from_state] = project.state
      project.state = transition.to_state
    end

    # After transition run, persist the current state
    # into model.state field.
    after_transition do |project, transition|
      project.save(validate: false) # make sure state persists even if project is invalid
      next if transition.metadata['skip_callbacks']
      from_state = transition.metadata[:from_state]

      project.notify_observers :"from_#{from_state}_to_#{transition.to_state}"
      project.index_on_common
    end

    after_transition(to: :successful) do |project|
      BalanceTransaction.insert_successful_project_transactions(project.id)
    end
  end

  setup_machine do
    transition from: :deleted, to: %i[draft]
    transition from: :rejected, to: %i[draft deleted]
    transition from: :draft, to: %i[rejected deleted online]
    transition from: :online, to: %i[draft rejected deleted waiting_funds successful failed]
    transition from: :waiting_funds, to: %i[successful failed rejected]
    transition from: :failed, to: %i[deleted rejected]
    transition from: :successful, to: :rejected

    guard_transition(from: :successful, to: :rejected) do |project, transition|
      project.can_cancel?
    end
  end

  def can_reject?
    can_transition_to? :rejected
  end

  def can_push_to_draft?
    can_transition_to? :draft
  end

  def can_push_to_trash?
    can_transition_to? :deleted
  end

  def can_push_to_online?
    can_transition_to? :online
  end

  # put project into deleted state
  def push_to_trash
    transition_to :deleted, to_state: 'deleted'
  end

  # put project into draft state
  def push_to_draft
    transition_to :draft, to_state: 'draft'
  end

  # put project in rejected state
  def reject
    transition_to :rejected, to_state: 'rejected'
  end

  # put project in online state
  def push_to_online
    transition_to :online, to_state: 'online'
  end

  def fake_push_to_online
    transition_to(:online, to_state: 'online', skip_callbacks: true)
  end

  # put project in successful or waiting_funds state
  def finish
    transition_to(:waiting_funds, to_state: 'waiting_funds') || transition_to(:failed, to_state: 'failed') || transition_to(:successful, to_state: 'successful')
  end
end
