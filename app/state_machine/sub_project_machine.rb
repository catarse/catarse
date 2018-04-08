# frozen_string_literal: true

class SubProjectMachine
  include Statesman::Machine

  def self.basic_validation_states
    %i[online].freeze
  end

  def self.setup_machine
    state :draft, initial: true
    state :online
    state :deleted
    state :successful
    state :rejected

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

  end

  setup_machine do
    transition from: :deleted, to: %i[draft]
    transition from: :draft, to: %i[deleted online]
    transition from: :online, to: %i[draft deleted successful rejected]
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

  # put project in online state
  def push_to_online
    transition_to :online, to_state: 'online'
  end

  def fake_push_to_online
    transition_to(:online, to_state: 'online', skip_callbacks: true)
  end

  def finish
    transition_to(:successful, to_state: 'successful')
  end
end
