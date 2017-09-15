# frozen_string_literal: true

class SubProjectMachine
  include Statesman::Machine

  def self.basic_validation_states
    %i[online].freeze
  end

  def self.setup_machine
    state :draft, initial: true
    state :deleted
    state :online

    # this block receive all transition
    # definitions
    yield self if block_given?

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
    end

  end

  setup_machine do
    transition from: :draft, to: %i[online deleted]
    transition from: :online, to: %i[draft deleted]
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

end
