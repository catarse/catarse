class AonProjectMachine < FlexProjectMachine
  def self.basic_validation_states
    %i(in_analysis approved online waiting_funds successful failed).freeze
  end

  setup_machine do
    state :in_analysis
    state :approved

    transition from: :deleted, to: %i(draft)
    transition from: :rejected, to: %i(draft deleted)
    transition from: :draft, to: %i(rejected deleted in_analysis online)
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

end
