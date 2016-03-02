class AonProjectMachine < FlexProjectMachine
  def self.basic_validation_states
    %i(in_analysis approved online waiting_funds successful failed).freeze
  end

  def self.need_expiration_states
    %i(waiting_funds successful failed).freeze
  end

  def self.finished_states
    %i(successful failed).freeze
  end

  setup_machine do
    state :in_analysis
    state :approved

    transition from: :rejected, to: %i(draft deleted)
    transition from: :draft, to: %i(rejected deleted in_analysis)
    transition from: :in_analysis, to: %i(approved rejected draft deleted)
    transition from: :approved, to: %i(online in_analysis)
    transition from: :online, to: %i(waiting_funds successful failed)
    transition from: :waiting_funds, to: %i(successful failed)

    guard_transition(to: :failed) do |project|
      !project.reached_goal?
    end

    guard_transition(to: :successful) do |project|
      project.reached_goal?
    end
  end

  def send_to_analysis
    transition_to :in_analysis, to_state: 'in_analysis'
  end

  def approve
    transition_to :approved, to_state: 'approved'
  end

  def finish
    transition_to(:waiting_funds, to_state: 'waiting_funds') || transition_to(:failed, to_state: 'failed') || transition_to(:successful, to_state: 'successful') || send_errors_to_admin
  end

  def can_approve?
    can_transition_to? :approved
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
end
