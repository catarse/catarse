class FlexibleProject < Project
  FINAL_LAP_INTERVAL = 7
  include Project::BaseValidator

  # delegate reusable methods from state_machine
  delegate :push_to_online, :finish, :push_to_draft,
    :push_to_trash, :reject, to: :state_machine

  def self.sti_name
    'flex'
  end

  # instace of a flexible project state machine
  def state_machine
    @state_machine ||= FlexProjectMachine.new(self, {
      transition_class: ProjectTransition
    })
  end

  def announce_expiration
    if self.expires_at.nil?
      self.project.update_attribute :expires_at, FINAL_LAP_INTERVAL.days.from_now.end_of_day
    end
  end

end
